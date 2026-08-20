import Foundation
import Combine

enum GameState {
    case idle          // waiting for a tap
    case prompting     // playing the word out loud
    case listening     // waiting for the child to say it back
    case feedback      // playing the success/try-again tone
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var currentWord: WordItem
    @Published private(set) var currentLanguage: Language
    @Published private(set) var state: GameState = .idle

    private let progressStore = ProgressStore()
    private let audio = AudioPlaybackService()
    private let speech = SpeechRecognitionService()
    private let tones = ToneGenerator()
    private lazy var rotation = RotationEngine(progressStore: progressStore)

    private var permissionsGranted = false

    init() {
        currentWord = WordLibrary.all.randomElement()!
        currentLanguage = .english
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        speech.requestAuthorization { [weak self] granted in
            self?.permissionsGranted = granted
            completion(granted)
        }
    }

    /// The child tapped the picture. Speak the word, then listen for her reply.
    func tapPicture() {
        guard state == .idle, permissionsGranted else { return }

        state = .prompting
        let word = currentWord
        let language = currentLanguage

        audio.speak(word: word, language: language) { [weak self] in
            self?.beginListening(word: word, language: language)
        }
    }

    private func beginListening(word: WordItem, language: Language) {
        state = .listening
        speech.listen(for: word.word(for: language), language: language) { [weak self] outcome in
            self?.handle(outcome: outcome, word: word, language: language)
        }
    }

    private func handle(outcome: SpeechRecognitionService.Outcome, word: WordItem, language: Language) {
        state = .feedback

        switch outcome {
        case .matched:
            progressStore.recordAttempt(wordId: word.id, language: language, correct: true)
            tones.playSuccess()
        case .notMatched:
            progressStore.recordAttempt(wordId: word.id, language: language, correct: false)
            tones.playTryAgain()
        case .unavailable:
            // Don't penalize the child for a device/language limitation.
            tones.playTryAgain()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.advance()
        }
    }

    private func advance() {
        let next = rotation.nextRound()
        currentWord = next.word
        currentLanguage = next.language
        state = .idle
    }
}
