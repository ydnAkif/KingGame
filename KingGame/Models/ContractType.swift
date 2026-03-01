import Foundation

// MARK: - Contract Type
enum ContractType: String, CaseIterable, Codable, Equatable {
    // CEZALAR
    case noTricks    = "El Almaz"
    case noHearts    = "Kupa Almaz"
    case noQueens    = "Kız Almaz"
    case noMales     = "Erkek Almaz"
    case lastTwo     = "Son İki"
    case rifki       = "Rıfkı"
    
    // KOZLAR
    case trumpSpades   = "Maça Koz"
    case trumpHearts   = "Kupa Koz"
    case trumpDiamonds = "Karo Koz"
    case trumpClubs    = "Sinek Koz"
    
    // MARK: - Temel Özellikler
    
    var isTrump: Bool {
        switch self {
        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            return true
        default:
            return false
        }
    }
    
    var isPenalty: Bool {
        return !isTrump
    }
    
    // Kozun rengi
    var trumpSuit: Suit? {
        switch self {
        case .trumpSpades:   return .spades
        case .trumpHearts:   return .hearts
        case .trumpDiamonds: return .diamonds
        case .trumpClubs:    return .clubs
        default:             return nil
        }
    }
    
    // MARK: - Puan Hesaplama
    
    // Koz: löve başına +50
    var trickScore: Int {
        return isTrump ? 50 : 0
    }
    
    // Ceza puanı hesapla
    func penaltyScore(for card: Card, trickNumber: Int, totalTricks: Int) -> Int {
        switch self {
            
        case .noTricks:
            // Her löve -50
            return -50
            
        case .noHearts:
            // Her kupa -30
            return card.isHeart ? -30 : 0
            
        case .noQueens:
            // Her Q -100
            return card.isQueen ? -100 : 0
            
        case .noMales:
            // Her K veya J -60
            return card.isMale ? -60 : 0
            
        case .lastTwo:
            // Sadece 12. ve 13. löve -180
            let isLastTwo = trickNumber == totalTricks || trickNumber == totalTricks - 1
            return isLastTwo ? -180 : 0
            
        case .rifki:
            // Kupa Papaz -320
            return card.isRifki ? -320 : 0
            
        default:
            return 0
        }
    }
    
    // MARK: - Sembol
    var symbol: String {
        switch self {
        case .noTricks:      return "🚫"
        case .noHearts:      return "♥"
        case .noQueens:      return "👑"
        case .noMales:       return "🤴"
        case .lastTwo:       return "2️⃣"
        case .rifki:         return "💀"
        case .trumpSpades:   return "♠"
        case .trumpHearts:   return "♥"
        case .trumpDiamonds: return "♦"
        case .trumpClubs:    return "♣"
        }
    }
    
    // MARK: - Renk (UI için)
    var colorName: String {
        switch self {
        case .noHearts, .rifki, .trumpHearts:     return "red"
        case .trumpDiamonds, .noQueens:            return "orange"
        case .trumpSpades, .noTricks:              return "black"
        case .trumpClubs, .noMales:                return "green"
        case .lastTwo:                             return "purple"
        }
    }
}

// MARK: - Bidding Tracker
// Tüm oyunda hangi kontratlar kaç kez seçildi
struct BiddingTracker {
    // Ceza türü → kaç kez seçildi (max 2)
    private var penaltyCounts: [ContractType: Int] = [:]
    
    // Her oyuncunun seçtiği kontratlar
    private var playerContracts: [UUID: [ContractType]] = [:]
    
    // Bir ceza türü hâlâ seçilebilir mi?
    func canSelectPenalty(_ contract: ContractType) -> Bool {
        guard contract.isPenalty else { return false }
        return (penaltyCounts[contract] ?? 0) < 2
    }
    
    // Oyuncu koz seçebilir mi?
    func canSelectTrump(player: Player, currentRound: Int) -> Bool {
        // İlk 4 seçimde koz yasak
        if currentRound <= 4 { return false }
        
        let contracts = playerContracts[player.id] ?? []
        let trumpCount = contracts.filter { $0.isTrump }.count
        return trumpCount < 2  // max 2 koz hakkı
    }
    
    // Oyuncu ceza seçebilir mi?
    func canSelectPenalty(player: Player) -> Bool {
        let contracts = playerContracts[player.id] ?? []
        let penaltyCount = contracts.filter { $0.isPenalty }.count
        return penaltyCount < 3  // max 3 ceza hakkı
    }
    
    // Kontrat seç
    mutating func select(_ contract: ContractType, for player: Player) {
        // Oyuncuya ekle
        if playerContracts[player.id] == nil {
            playerContracts[player.id] = []
        }
        playerContracts[player.id]?.append(contract)
        
        // Ceza sayacını artır
        if contract.isPenalty {
            penaltyCounts[contract, default: 0] += 1
        }
    }
    
    // Oyuncunun seçtikleri
    func contracts(for player: Player) -> [ContractType] {
        return playerContracts[player.id] ?? []
    }
    
    // Oyuncunun kaç kozu var?
    func trumpCount(for player: Player) -> Int {
        return (playerContracts[player.id] ?? []).filter { $0.isTrump }.count
    }
    
    // Oyuncunun kaç cezası var?
    func penaltyCount(for player: Player) -> Int {
        return (playerContracts[player.id] ?? []).filter { $0.isPenalty }.count
    }
}
