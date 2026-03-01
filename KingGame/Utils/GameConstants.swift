import Foundation
import SwiftUI

// MARK: - Oyun Sabitleri
struct GameConstants {
    // Ekran Boyutları
    static let minScreenWidth: CGFloat = 1050
    static let minScreenHeight: CGFloat = 780

    // Kart Boyutları
    static let cardWidth: CGFloat = 100
    static let cardHeight: CGFloat = 140  // width * 1.4
    static let cardSpacing: CGFloat = -55  // Negatif: kartlar üst üste biner
    static let cardHoverScale: CGFloat = 1.15
    static let cardNeighborScale: CGFloat = 1.05
    static let cardSelectOffset: CGFloat = -40
    static let cardHoverOffset: CGFloat = -25
    static let cardFanAngle: Double = 3.5  // Yelpaze açısı (derece)

    // Oyuncu Paneli
    static let playerPanelWidth: CGFloat = 110
    static let playerPanelHeight: CGFloat = 65
    static let playerCardBackWidth: CGFloat = 44
    static let playerCardBackSpacing: CGFloat = 12

    // Masa Boyutları
    static let tableCornerRadius: CGFloat = 32
    static let tablePaddingHorizontal: CGFloat = 240
    static let tablePaddingVertical: CGFloat = 400

    // TrickPile (Masada Oynanan Kartlar)
    static let trickPileDiameter: CGFloat = 260
    static let trickPileCardWidth: CGFloat = 110
    static let trickPileOffset: CGFloat = 130  // Kartların merkeze uzaklığı
    static let trickGatherOffset: CGFloat = 350  // Toplanma uçış noktası

    // Modal Boyutları
    static let modalCornerRadius: CGFloat = 32
    static let modalMaxWidth: CGFloat = 600
    static let modalPadding: CGFloat = 32

    // Buton Boyutları
    static let trumpButtonSize: CGFloat = 72
    static let trumpButtonCornerRadius: CGFloat = 16
    static let penaltyButtonHeight: CGFloat = 46
    static let penaltyButtonCornerRadius: CGFloat = 14

    // Animasyon Süreleri
    static let cardPlayAnimationDuration: Double = 0.3
    static let cardHoverAnimationDuration: Double = 0.25
    static let trickGatherAnimationDuration: Double = 0.6
    static let phaseTransitionDuration: Double = 0.4

    // AI Gecikmeleri (saniye)
    static let aiPlayDelay: Double = 0.5
    static let aiBiddingDelay: Double = 0.6
    static let trickGatherDelay: Double = 1.8
    static let trickGatherDelayExtended: Double = 2.5  // Rıfkı/erken bitiş için

    // Skor Tablosu
    static let scoreRowHeight: CGFloat = 40
    static let scoreHeaderHeight: CGFloat = 44
    static let scoreColumnWidth: CGFloat = 120

    // Renkler (GameBoardView extension'ı ile uyumlu)
    static let woodDark = Color(red: 0.35, green: 0.18, blue: 0.05)
    static let woodMid = Color(red: 0.55, green: 0.30, blue: 0.10)
    static let feltGreen = Color(red: 0.10, green: 0.42, blue: 0.15)
    static let feltDark = Color(red: 0.07, green: 0.30, blue: 0.10)
    static let goldLight = Color(red: 1.00, green: 0.82, blue: 0.20)
    static let goldMid = Color(red: 0.90, green: 0.65, blue: 0.10)
    static let goldDark = Color(red: 0.70, green: 0.45, blue: 0.05)
    static let plateDark = Color(red: 0.12, green: 0.12, blue: 0.12)

    // Oyun Kuralları
    static let totalRounds = 20
    static let totalTricks = 13
    static let maxTrumpPerPlayer = 2
    static let maxPenaltyPerPlayer = 3
    static let maxPenaltyTypeCount = 2  // Her ceza türü max 2 kez seçilebilir
    static let firstTrumpRound = 5  // İlk 4 el koz seçilemez

    // Puanlama
    static let trumpTrickScore = 50
    static let noTricksPenalty = -50
    static let noHeartsPenalty = -30
    static let noQueensPenalty = -100
    static let noMalesPenalty = -60
    static let lastTwoPenalty = -180
    static let rifkiPenalty = -320
    static let kingBonus = 12
    static let kingPenalty = -4
    static let gameWinBonus = 12
    static let gameBestBonus = 3
}

// MARK: - UI Yardımcılar
struct UIConstants {
    // Font Boyutları
    static let titleLarge: CGFloat = 40
    static let titleMedium: CGFloat = 32
    static let titleSmall: CGFloat = 28
    static let bodyLarge: CGFloat = 16
    static let bodyMedium: CGFloat = 14
    static let bodySmall: CGFloat = 11
    static let caption: CGFloat = 9

    // Font Ağırlıkları
    static let fontWeightHeavy = Font.Weight.heavy
    static let fontWeightBold = Font.Weight.bold
    static let fontWeightSemibold = Font.Weight.semibold
    static let fontWeightMedium = Font.Weight.medium
    static let fontWeightRegular = Font.Weight.regular

    // Corner Radius
    static let cornerRadiusLarge: CGFloat = 32
    static let cornerRadiusMedium: CGFloat = 20
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusTiny: CGFloat = 6

    // Shadow
    static let shadowRadiusLarge: CGFloat = 40
    static let shadowRadiusMedium: CGFloat = 20
    static let shadowRadiusSmall: CGFloat = 8

    // Opacity
    static let opacityHigh: CGFloat = 0.9
    static let opacityMedium: CGFloat = 0.6
    static let opacityLow: CGFloat = 0.4
    static let opacityVeryLow: CGFloat = 0.15
}

// MARK: - Accessibilty
struct AccessibilityConstants {
    static let cardLabelFormat = "%@ %@"  // "King Spades"
    static let playerTurnLabel = "%@ oynuyor"
    static let contractSelectedLabel = "%@ kontratı seçildi"
    static let trickWonLabel = "%@ löveyi aldı"
    static let kingAchievedLabel = "KING! %@ 11 löve aldı"
}
