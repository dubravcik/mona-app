import Foundation

/// Persists per-word, per-language attempt/success counts to disk (Documents dir,
/// fully offline, survives app restarts) so missed words get repeated more often.
final class ProgressStore {
    struct Stat: Codable {
        var attempts: Int = 0
        var correct: Int = 0
    }

    private var stats: [String: Stat] = [:]
    private let fileURL: URL
    private let queue = DispatchQueue(label: "ProgressStore.queue")

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("progress.json")
        load()
    }

    private func key(_ wordId: String, _ language: Language) -> String {
        "\(language.rawValue)_\(wordId)"
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: Stat].self, from: data) else { return }
        stats = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func recordAttempt(wordId: String, language: Language, correct: Bool) {
        queue.sync {
            var stat = stats[key(wordId, language)] ?? Stat()
            stat.attempts += 1
            if correct { stat.correct += 1 }
            stats[key(wordId, language)] = stat
            persist()
        }
    }

    /// Higher weight = picked more often. Never-tried words and words missed
    /// recently get a bigger weight than words the child already knows well.
    func weight(for wordId: String, language: Language) -> Double {
        queue.sync {
            guard let stat = stats[key(wordId, language)], stat.attempts > 0 else {
                return 3.0 // unseen word: prioritize introducing it
            }
            let successRate = Double(stat.correct) / Double(stat.attempts)
            // successRate 0 -> weight 3.0, successRate 1 -> weight 0.4
            return 3.0 - (successRate * 2.6)
        }
    }
}
