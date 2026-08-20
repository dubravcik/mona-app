import Foundation

/// One of the 30 objects the child learns, with its word in all four languages.
struct WordItem: Identifiable, Codable {
    /// Stable id, also used as the recording/photo filename stem (e.g. "apple").
    let id: String
    /// Default picture when no real photo has been added by the parent.
    let emoji: String
    let words: [Language: String]

    func word(for language: Language) -> String {
        words[language] ?? id
    }
}
