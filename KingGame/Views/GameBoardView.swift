import SwiftUI

// MARK: - Renk Paleti
extension Color {
    static let woodDark  = Color(red: 0.35, green: 0.18, blue: 0.05)
    static let woodMid   = Color(red: 0.55, green: 0.30, blue: 0.10)
    static let feltGreen = Color(red: 0.10, green: 0.42, blue: 0.15)
    static let feltDark  = Color(red: 0.07, green: 0.30, blue: 0.10)
    static let goldLight = Color(red: 1.00, green: 0.82, blue: 0.20)
    static let goldMid   = Color(red: 0.90, green: 0.65, blue: 0.10)
    static let goldDark  = Color(red: 0.70, green: 0.45, blue: 0.05)
    static let plateDark = Color(red: 0.12, green: 0.12, blue: 0.12)
}

// MARK: - Oyuncu Plakası
struct PlayerPlate: View {
    let player: Player
    let isActive: Bool
    let vertical: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(player.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("\(player.totalScore)")
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .foregroundColor(player.totalScore >= 0 ? .green : Color(red:1, green:0.3, blue:0.3))
            // El puanı (oyun sırasında)
            if player.roundScore != 0 {
                Text("(\(player.roundScore > 0 ? "+" : "")\(player.roundScore))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(player.roundScore > 0 ? .green.opacity(0.7) : Color(red:1, green:0.4, blue:0.4).opacity(0.8))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.plateDark.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? Color.goldLight : Color.white.opacity(0.15),
                                lineWidth: isActive ? 2.5 : 0.5)
                )
                .shadow(color: isActive ? Color.goldLight.opacity(0.3) : .black.opacity(0.5), radius: isActive ? 8 : 4, x: 0, y: 2)
        )
        .scaleEffect(isActive ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

// MARK: - Yenilen Kart Badge
struct EatenCardBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .heavy, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(color.opacity(0.3), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - GameBoardView
struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    private let dummyCard = Card(suit: .spades, rank: .two)

    func direction(for player: Player) -> TableDirection {
        guard let i = gameState.players.firstIndex(where: { $0.id == player.id }) else { return .south }
        switch i {
        case 0: return .south
        case 1: return .north
        case 2: return .west
        case 3: return .east
        default: return .south
        }
    }

    func player(at dir: TableDirection) -> Player {
        switch dir {
        case .south: return gameState.players[0]
        case .north: return gameState.players[1]
        case .west:  return gameState.players[2]
        case .east:  return gameState.players[3]
        }
    }

    // MARK: - Yenilen Kartlar (contract'a göre)
    @ViewBuilder
    func eatenCardsView(for player: Player) -> some View {
        if let round = gameState.currentRound {
            switch round.contract {
            case .noQueens:
                let cards = player.wonCards.filter { $0.isQueen }
                if !cards.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(cards, id: \.id) { card in
                            EatenCardBadge(
                                text: card.shortName,
                                color: card.suit.isRed ? Color(red:1, green:0.3, blue:0.3) : .white
                            )
                        }
                    }
                }
            case .noMales:
                let cards = player.wonCards.filter { $0.isMale }
                if !cards.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(cards, id: \.id) { card in
                            EatenCardBadge(
                                text: card.shortName,
                                color: card.suit.isRed ? Color(red:1, green:0.3, blue:0.3) : .white
                            )
                        }
                    }
                }
            case .noHearts, .rifki:
                let cards = player.wonCards.filter { $0.isHeart }
                if !cards.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(cards, id: \.id) { card in
                            EatenCardBadge(
                                text: card.shortName,
                                color: Color(red:1, green:0.3, blue:0.3)
                            )
                        }
                    }
                }
            case .noTricks:
                if player.tricksWon > 0 {
                    EatenCardBadge(
                        text: "\(player.tricksWon) el",
                        color: .white.opacity(0.8)
                    )
                }
            case .lastTwo:
                if player.tricksWon > 0 {
                    EatenCardBadge(
                        text: "\(player.tricksWon) el",
                        color: .white.opacity(0.8)
                    )
                }
            default:
                if player.tricksWon > 0 {
                    EatenCardBadge(
                        text: "\(player.tricksWon) el",
                        color: .green.opacity(0.8)
                    )
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                woodBackground(size: geo.size)

                VStack(spacing: 0) {
                    northZone
                        .frame(height: 100)
                        .padding(.top, 12)

                    HStack(spacing: 0) {
                        westZone
                            .frame(width: 120)
                        centerZone
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        eastZone
                            .frame(width: 120)
                    }
                    .frame(maxHeight: .infinity)

                    southZone
                        .padding(.bottom, 10)
                }

                VStack {
                    topInfoBar
                    Spacer()
                }
            }
        }
        .frame(minWidth: 1050, minHeight: 780)
    }

    // MARK: - Arka Plan
    func woodBackground(size: CGSize) -> some View {
        ZStack {
            Color.woodDark
            RoundedRectangle(cornerRadius: 24)
                .fill(RadialGradient(
                    colors: [Color.feltGreen, Color.feltDark],
                    center: .center, startRadius: 10, endRadius: 500
                ))
                .padding(EdgeInsets(top: 100, leading: 120, bottom: 290, trailing: 120))
        }
        .ignoresSafeArea()
    }

    // MARK: - Üst Bilgi Bandı
    var topInfoBar: some View {
        HStack {
            if let round = gameState.currentRound {
                HStack(spacing: 8) {
                    Text(round.contract.symbol).font(.system(size: 18))
                    Text(round.contract.rawValue.uppercased())
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                    Text("El \(gameState.roundNumber)/20")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    if round.heartsOpened {
                        Text("  ACIK")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red:1, green:0.4, blue:0.4))
                    }
                    if round.contract.isTrump && round.trumpOpened {
                        Text("KOZ ACIK")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.goldLight)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Color.black.opacity(0.6)).cornerRadius(20)
            }
            Spacer()
            trickCounterBar
        }
        .padding(.horizontal, 16).padding(.top, 8)
    }

    var trickCounterBar: some View {
        HStack(spacing: 6) {
            ForEach(gameState.players) { p in
                VStack(spacing: 1) {
                    Text(p.name.components(separatedBy: "-").first?.prefix(3) ?? "")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(p.tricksWon)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .frame(width: 38, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(gameState.currentPlayer.id == p.id
                              ? Color.goldMid.opacity(0.3) : Color.black.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(gameState.currentPlayer.id == p.id
                                    ? Color.goldLight : Color.clear, lineWidth: 1.5))
                )
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Color.black.opacity(0.4)).cornerRadius(12)
    }

    // MARK: - KUZEY
    var northZone: some View {
        let p = player(at: .north)
        let isActive = gameState.currentPlayer.id == p.id
        return VStack(spacing: 4) {
            HStack(spacing: 8) {
                PlayerPlate(player: p, isActive: isActive, vertical: false)
                eatenCardsView(for: p)
            }
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    let angle = Double(i - p.hand.count/2) * 3.0
                    CardView(card: dummyCard, faceDown: true, width: 44)
                        .rotationEffect(.degrees(angle + 180))
                        .offset(x: CGFloat(i - p.hand.count/2) * 12)
                }
            }
            .frame(height: 65)
        }
    }

    // MARK: - BATI
    var westZone: some View {
        let p = player(at: .west)
        let isActive = gameState.currentPlayer.id == p.id
        return VStack(spacing: 4) {
            PlayerPlate(player: p, isActive: isActive, vertical: false)
                .rotationEffect(.degrees(-90))
                .fixedSize()
            eatenCardsView(for: p)
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    CardView(card: dummyCard, faceDown: true, width: 40)
                        .rotationEffect(.degrees(90))
                        .offset(y: CGFloat(i - p.hand.count/2) * 10)
                }
            }
            .frame(width: 80, height: 180)
        }
        .frame(width: 120)
    }

    // MARK: - DOGU
    var eastZone: some View {
        let p = player(at: .east)
        let isActive = gameState.currentPlayer.id == p.id
        return VStack(spacing: 4) {
            PlayerPlate(player: p, isActive: isActive, vertical: false)
                .rotationEffect(.degrees(90))
                .fixedSize()
            eatenCardsView(for: p)
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    CardView(card: dummyCard, faceDown: true, width: 40)
                        .rotationEffect(.degrees(-90))
                        .offset(y: CGFloat(i - p.hand.count/2) * 10)
                }
            }
            .frame(width: 80, height: 180)
        }
        .frame(width: 120)
    }

    // MARK: - MERKEZ
    var centerZone: some View {
        VStack(spacing: 12) {
            Spacer()
            TrickPileView(
                trick: gameState.currentRound?.currentTrick,
                directionOf: { direction(for: $0) }
            )
            Spacer()
        }
    }

    // MARK: - GUNEY
    var southZone: some View {
        let human = player(at: .south)
        let isActive = gameState.currentPlayer.id == human.id && gameState.phase == .playing

        let validCards: [Card] = isActive ? RuleEngine.validCards(
            for: human,
            trick: gameState.currentRound?.currentTrick,
            round: gameState.currentRound ?? Round(roundNumber: 0, contract: .noTricks, contractOwner: human),
            heartsOpened: gameState.currentRound?.heartsOpened ?? false
        ) : []

        return VStack(spacing: 6) {
            HStack(spacing: 12) {
                PlayerPlate(player: human, isActive: isActive, vertical: false)
                eatenCardsView(for: human)
                if isActive {
                    Text("KARTINIZI SECIN")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.goldLight)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.goldDark.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.goldLight.opacity(0.4), lineWidth: 1)
                                )
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            PlayerHandView(
                player: human,
                validCards: validCards,
                onCardSelected: { card in gameState.playCard(card, by: human) }
            )
        }
    }
}
