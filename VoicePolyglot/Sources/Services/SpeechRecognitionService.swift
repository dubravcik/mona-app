import Speech
import AVFoundation

/// Listens for the child's spoken reply and checks it against the expected word,
/// entirely on-device (requiresOnDeviceRecognition = true) so it keeps working
/// with no internet connection once iOS has the language's dictation model
/// installed. Tolerant of a toddler's imperfect pronunciation via fuzzy matching.
final class SpeechRecognitionService {
    enum Outcome {
        case matched
        case notMatched
        case unavailable // on-device recognition not supported for this language on this device
    }

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                DispatchQueue.main.async {
                    completion(status == .authorized && micGranted)
                }
            }
        }
    }

    /// Listens for up to `timeout` seconds, then reports whether the heard
    /// speech matched `expectedWord`. Calls `onFinished` exactly once.
    func listen(for expectedWord: String, language: Language, timeout: TimeInterval = 4.0, onFinished: @escaping (Outcome) -> Void) {
        stop()

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language.localeIdentifier)),
              recognizer.isAvailable else {
            onFinished(.unavailable)
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            onFinished(.unavailable)
            return
        }

        var finished = false
        let finishOnce: (Outcome) -> Void = { [weak self] outcome in
            guard !finished else { return }
            finished = true
            self?.stop()
            onFinished(outcome)
        }

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result, result.isFinal {
                let heard = result.bestTranscription.formattedString
                finishOnce(Self.matches(heard: heard, expected: expectedWord) ? .matched : .notMatched)
            } else if error != nil {
                finishOnce(.notMatched)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            request.endAudio()
            // Give the recognizer a brief moment to deliver a final result for
            // whatever audio was already captured before giving up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                finishOnce(.notMatched)
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }

    /// Loose comparison: case/diacritic-insensitive, ignores surrounding
    /// whitespace/punctuation, and tolerates a one-character slip for a
    /// toddler's approximate pronunciation.
    private static func matches(heard: String, expected: String) -> Bool {
        let normalizedHeard = normalize(heard)
        let normalizedExpected = normalize(expected)
        if normalizedHeard.isEmpty { return false }
        if normalizedHeard == normalizedExpected { return true }
        if normalizedHeard.contains(normalizedExpected) || normalizedExpected.contains(normalizedHeard) { return true }
        return levenshtein(normalizedHeard, normalizedExpected) <= 1
    }

    private static func normalize(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = Swift.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
            }
            previous = current
        }
        return previous[b.count]
    }
}
