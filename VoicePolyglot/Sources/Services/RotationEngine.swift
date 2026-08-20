import Foundation

/// Picks what's next: cycles through the four languages round-robin, and within
/// each language weights word choice toward words the child hasn't learned yet
/// or has recently missed (see ProgressStore.weight).
final class RotationEngine {
    private let progressStore: ProgressStore
    private var currentLanguage: Language
    private var lastWordId: String?

    init(progressStore: ProgressStore, startingLanguage: Language = .english) {
        self.progressStore = progressStore
        self.currentLanguage = startingLanguage
    }

    /// Advances to the next language and returns a freshly chosen (word, language) pair.
    func nextRound() -> (word: WordItem, language: Language) {
        currentLanguage = currentLanguage.next
        let word = pickWord(excluding: lastWordId)
        lastWordId = word.id
        return (word, currentLanguage)
    }

    private func pickWord(excluding excludedId: String?) -> WordItem {
        let candidates = WordLibrary.all.filter { $0.id != excludedId }
        let pool = candidates.isEmpty ? WordLibrary.all : candidates

        let weights = pool.map { progressStore.weight(for: $0.id, language: currentLanguage) }
        let total = weights.reduce(0, +)
        guard total > 0 else { return pool.randomElement()! }

        var pick = Double.random(in: 0..<total)
        for (item, weight) in zip(pool, weights) {
            if pick < weight { return item }
            pick -= weight
        }
        return pool.last!
    }
}
