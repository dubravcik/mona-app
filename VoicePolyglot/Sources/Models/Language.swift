import Foundation

/// The four languages taught in rotation. Order here is the rotation order.
enum Language: String, CaseIterable, Codable, Identifiable {
    case english
    case spanish
    case mandarin
    case japanese

    var id: String { rawValue }

    /// Locale used for both speech synthesis and on-device speech recognition.
    var localeIdentifier: String {
        switch self {
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .mandarin: return "zh-CN"
        case .japanese: return "ja-JP"
        }
    }

    /// Short code used to key recording filenames, e.g. "en_apple.m4a".
    var fileCode: String {
        switch self {
        case .english: return "en"
        case .spanish: return "es"
        case .mandarin: return "zh"
        case .japanese: return "ja"
        }
    }

    var next: Language {
        let all = Language.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}
