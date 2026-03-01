import Foundation
import Combine

// MARK: - Player Type
enum PlayerType {
    case human
    case aiAggressive   // AI-Agresif  (risk eşiği: %35)
    case aiBalanced     // AI-Dengeli  (risk eşiği: %50)
    case aiCalculator   // AI-Hesapçı  (risk eşiği: %25)
}

// MARK: - Player
class Player: ObservableObject, Identifiable {
    let id: UUID
    let name: String
    let type: PlayerType
    
    @Published var hand: [Card] = []        // Eldeki kartlar
    @Published var tricksWon: Int = 0       // Bu elde aldığı löve sayısı
    @Published var roundScore: Int = 0      // Bu kontratın puanı
    @Published var totalScore: Int = 0      // Toplam puan
    
    // Kupa çıktı mı takibi (Kupa Almaz ve Rıfkı için)
    var heartsPlayed: Bool = false
    
    var wonCards: [Card] = []
    
    init(name: String, type: PlayerType) {
        self.id   = UUID()
        self.name = name
        self.type = type
    }
    
    // MARK: - El İşlemleri
    
    // Kart oyna (elden çıkar)
    func playCard(_ card: Card) -> Card? {
        guard let index = hand.firstIndex(of: card) else { return nil }
        return hand.remove(at: index)
    }
    
    // Belirli renkte kart var mı?
    func hasCard(suit: Suit) -> Bool {
        return hand.contains { $0.suit == suit }
    }
    
    // Belirli renkte Queen var mı?
    func hasQueen(suit: Suit) -> Bool {
        return hand.contains { $0.suit == suit && $0.rank == .queen }
    }
    
    // Erkek kart var mı? (K veya J)
    func hasMaleCard(suit: Suit) -> Bool {
        return hand.contains { $0.suit == suit && ($0.rank == .king || $0.rank == .jack) }
    }
    
    // Kupa Papaz elimde mi?
    var hasRifki: Bool {
        return hand.contains { $0.isRifki }
    }
    
    // Löve al
    func winTrick() {
        tricksWon += 1
    }
    
    // Yeni kontrat için sıfırla
    func resetForNewRound() {
        tricksWon  = 0
        roundScore = 0
        wonCards = []
    }
    
    // Yeni oyun için sıfırla
    func resetForNewGame() {
        hand        = []
        tricksWon   = 0
        roundScore  = 0
        totalScore  = 0
        heartsPlayed = false
    }
    
    // AI mi?
    var isAI: Bool {
        return type != .human
    }
    
    // Risk eşiği
    var riskThreshold: Double {
        switch type {
        case .human:          return 1.0
        case .aiAggressive:   return 0.35
        case .aiBalanced:     return 0.50
        case .aiCalculator:   return 0.25
        }
    }
}
