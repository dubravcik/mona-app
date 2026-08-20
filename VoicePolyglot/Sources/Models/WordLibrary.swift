import Foundation

/// The fixed set of 30 objects taught on rotation across all four languages.
/// Edit this list to change vocabulary — everything else adapts automatically.
enum WordLibrary {
    static let all: [WordItem] = [
        WordItem(id: "apple", emoji: "🍎", words: [.english: "apple", .spanish: "manzana", .mandarin: "苹果", .japanese: "りんご"]),
        WordItem(id: "ball", emoji: "⚽️", words: [.english: "ball", .spanish: "pelota", .mandarin: "球", .japanese: "ボール"]),
        WordItem(id: "banana", emoji: "🍌", words: [.english: "banana", .spanish: "plátano", .mandarin: "香蕉", .japanese: "バナナ"]),
        WordItem(id: "bear", emoji: "🐻", words: [.english: "bear", .spanish: "oso", .mandarin: "熊", .japanese: "くま"]),
        WordItem(id: "bed", emoji: "🛏️", words: [.english: "bed", .spanish: "cama", .mandarin: "床", .japanese: "ベッド"]),
        WordItem(id: "bird", emoji: "🐦", words: [.english: "bird", .spanish: "pájaro", .mandarin: "鸟", .japanese: "とり"]),
        WordItem(id: "book", emoji: "📖", words: [.english: "book", .spanish: "libro", .mandarin: "书", .japanese: "ほん"]),
        WordItem(id: "bus", emoji: "🚌", words: [.english: "bus", .spanish: "autobús", .mandarin: "公共汽车", .japanese: "バス"]),
        WordItem(id: "car", emoji: "🚗", words: [.english: "car", .spanish: "coche", .mandarin: "车", .japanese: "くるま"]),
        WordItem(id: "cat", emoji: "🐱", words: [.english: "cat", .spanish: "gato", .mandarin: "猫", .japanese: "ねこ"]),
        WordItem(id: "chair", emoji: "🪑", words: [.english: "chair", .spanish: "silla", .mandarin: "椅子", .japanese: "いす"]),
        WordItem(id: "cow", emoji: "🐄", words: [.english: "cow", .spanish: "vaca", .mandarin: "牛", .japanese: "うし"]),
        WordItem(id: "cup", emoji: "☕️", words: [.english: "cup", .spanish: "taza", .mandarin: "杯子", .japanese: "コップ"]),
        WordItem(id: "dog", emoji: "🐶", words: [.english: "dog", .spanish: "perro", .mandarin: "狗", .japanese: "いぬ"]),
        WordItem(id: "door", emoji: "🚪", words: [.english: "door", .spanish: "puerta", .mandarin: "门", .japanese: "ドア"]),
        WordItem(id: "duck", emoji: "🦆", words: [.english: "duck", .spanish: "pato", .mandarin: "鸭子", .japanese: "あひる"]),
        WordItem(id: "egg", emoji: "🥚", words: [.english: "egg", .spanish: "huevo", .mandarin: "鸡蛋", .japanese: "たまご"]),
        WordItem(id: "fish", emoji: "🐟", words: [.english: "fish", .spanish: "pez", .mandarin: "鱼", .japanese: "さかな"]),
        WordItem(id: "flower", emoji: "🌸", words: [.english: "flower", .spanish: "flor", .mandarin: "花", .japanese: "はな"]),
        WordItem(id: "hand", emoji: "✋", words: [.english: "hand", .spanish: "mano", .mandarin: "手", .japanese: "て"]),
        WordItem(id: "hat", emoji: "🧢", words: [.english: "hat", .spanish: "sombrero", .mandarin: "帽子", .japanese: "ぼうし"]),
        WordItem(id: "horse", emoji: "🐴", words: [.english: "horse", .spanish: "caballo", .mandarin: "马", .japanese: "うま"]),
        WordItem(id: "house", emoji: "🏠", words: [.english: "house", .spanish: "casa", .mandarin: "房子", .japanese: "いえ"]),
        WordItem(id: "milk", emoji: "🥛", words: [.english: "milk", .spanish: "leche", .mandarin: "牛奶", .japanese: "ミルク"]),
        WordItem(id: "moon", emoji: "🌙", words: [.english: "moon", .spanish: "luna", .mandarin: "月亮", .japanese: "つき"]),
        WordItem(id: "shoe", emoji: "👞", words: [.english: "shoe", .spanish: "zapato", .mandarin: "鞋子", .japanese: "くつ"]),
        WordItem(id: "spoon", emoji: "🥄", words: [.english: "spoon", .spanish: "cuchara", .mandarin: "勺子", .japanese: "スプーン"]),
        WordItem(id: "star", emoji: "⭐️", words: [.english: "star", .spanish: "estrella", .mandarin: "星星", .japanese: "ほし"]),
        WordItem(id: "sun", emoji: "☀️", words: [.english: "sun", .spanish: "sol", .mandarin: "太阳", .japanese: "たいよう"]),
        WordItem(id: "tree", emoji: "🌳", words: [.english: "tree", .spanish: "árbol", .mandarin: "树", .japanese: "き"]),
    ]
}
