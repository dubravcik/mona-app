import AVFoundation

/// Plays the word prompt for a given word+language. Prefers a real recording of
/// the parents' own voices when one has been provided; falls back to on-device
/// speech synthesis (fully offline) otherwise.
///
/// Recording lookup order (first match wins):
///   1. Documents/Recordings/<langCode>_<wordId>.m4a  (added later via Files app,
///      no rebuild needed — e.g. "en_apple.m4a", "es_apple.m4a")
///   2. A file of the same name bundled into the app at build time.
final class AudioPlaybackService: NSObject {
    private var player: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    private var completion: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker])
    }

    func speak(word: WordItem, language: Language, completion: @escaping () -> Void) {
        if let url = recordingURL(wordId: word.id, language: language) {
            playRecording(at: url, completion: completion)
        } else {
            speakSynthesized(text: word.word(for: language), language: language, completion: completion)
        }
    }

    private func recordingURL(wordId: String, language: Language) -> URL? {
        let filename = "\(language.fileCode)_\(wordId).m4a"

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentsURL = documents.appendingPathComponent("Recordings").appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            return documentsURL
        }

        if let bundleURL = Bundle.main.url(forResource: "\(language.fileCode)_\(wordId)", withExtension: "m4a", subdirectory: "Recordings") {
            return bundleURL
        }

        return nil
    }

    private func playRecording(at url: URL, completion: @escaping () -> Void) {
        self.completion = completion
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            self.player = player
            player.play()
        } catch {
            speakSynthesized(text: url.deletingPathExtension().lastPathComponent, language: .english, completion: completion)
        }
    }

    private func speakSynthesized(text: String, language: Language, completion: @escaping () -> Void) {
        self.completion = completion
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.speak(utterance)
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let done = completion
        completion = nil
        done?()
    }
}

extension AudioPlaybackService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let done = completion
        completion = nil
        done?()
    }
}
