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
        HStack(spacing: 6) {
            Text(player.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("\(player.totalScore)")
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .foregroundColor(player.totalScore >= 0 ? .green : Color(red:1, green:0.3, blue:0.3))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.plateDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? Color.goldLight : Color.white.opacity(0.1),
                                lineWidth: isActive ? 2 : 0.5)
                )
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isActive ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

// MARK: - GameBoardView
struct GameBoardView: View {
    @ObservedObject var gameState: GameState

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
                    HStack(spacing: -8) {
                        ForEach(cards, id: \.id) { card in
                            CardView(card: card, isPlayable: false, width: 28)
                        }
                    }
                }
            case .noMales:
                let cards = player.wonCards.filter { $0.isMale }
                if !cards.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(cards, id: \.id) { card in
                            CardView(card: card, isPlayable: false, width: 28)
                        }
                    }
                }
            case .noHearts, .rifki:
                let cards = player.wonCards.filter { $0.isHeart }
                if !cards.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(cards, id: \.id) { card in
                            CardView(card: card, isPlayable: false, width: 28)
                        }
                    }
                }
            case .noTricks:
                Text("\(player.tricksWon)🃏")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            default:
                EmptyView()
            }
        }
    }

    var body: some View {
        ZStack {
            woodBackground
            VStack(spacing: 0) {
                northZone.padding(.top, 12)
                HStack(spacing: 0) {
                    westZone
                    centerZone.frame(maxWidth: .infinity, maxHeight: .infinity)
                    eastZone
                }
                .frame(maxHeight: .infinity)
                southZone.padding(.bottom, 10)
            }
            VStack {
                topInfoBar
                Spacer()
            }
        }
        .frame(minWidth: 1050, minHeight: 780)
    }

    // MARK: - Arka Plan
    var woodBackground: some View {
        ZStack {
            Color.woodDark
            RoundedRectangle(cornerRadius: 24)
                .fill(RadialGradient(
                    colors: [Color.feltGreen, Color.feltDark],
                    center: .center, startRadius: 10, endRadius: 500
                ))
                .padding(EdgeInsets(top: 100, leading: 110, bottom: 160, trailing: 110))
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
                        Text("♥ açık").font(.system(size: 10))
                            .foregroundColor(Color(red:1, green:0.4, blue:0.4))
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Color.black.opacity(0.5)).cornerRadius(20)
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
        return VStack(spacing: 6) {
            PlayerPlate(player: p, isActive: isActive, vertical: false)
            eatenCardsView(for: p)
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    let angle = Double(i - p.hand.count/2) * 3.5
                    CardView(card: Card(suit: .spades, rank: .two), faceDown: true, width: 52)
                        .rotationEffect(.degrees(angle + 180))
                        .offset(x: CGFloat(i - p.hand.count/2) * 14)
                }
            }
            .frame(height: 80)
        }
    }

    // MARK: - BATI
    var westZone: some View {
        let p = player(at: .west)
        let isActive = gameState.currentPlayer.id == p.id
        return VStack(spacing: 6) {
            PlayerPlate(player: p, isActive: isActive, vertical: false)
                .rotationEffect(.degrees(-90))
            eatenCardsView(for: p)
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    CardView(card: Card(suit: .spades, rank: .two), faceDown: true, width: 48)
                        .rotationEffect(.degrees(90))
                        .offset(y: CGFloat(i - p.hand.count/2) * 12)
                }
            }
            .frame(width: 95, height: 210)
        }
        .frame(width: 110)
    }

    // MARK: - DOĞU
    var eastZone: some View {
        let p = player(at: .east)
        let isActive = gameState.currentPlayer.id == p.id
        return VStack(spacing: 6) {
            PlayerPlate(player: p, isActive: isActive, vertical: false)
                .rotationEffect(.degrees(90))
            eatenCardsView(for: p)
            ZStack {
                ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                    CardView(card: Card(suit: .spades, rank: .two), faceDown: true, width: 48)
                        .rotationEffect(.degrees(-90))
                        .offset(y: CGFloat(i - p.hand.count/2) * 12)
                }
            }
            .frame(width: 95, height: 210)
        }
        .frame(width: 110)
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

    // MARK: - GÜNEY
    var southZone: some View {
        let human = player(at: .south)
        let isActive = gameState.currentPlayer.id == human.id && gameState.phase == .playing

        let validCards: [Card] = isActive ? RuleEngine.validCards(
            for: human,
            trick: gameState.currentRound?.currentTrick,
            round: gameState.currentRound ?? Round(roundNumber: 0, contract: .noTricks, contractOwner: human),
            heartsOpened: gameState.currentRound?.heartsOpened ?? false
        ) : []

        return VStack(spacing: 8) {
            HStack {
                PlayerPlate(player: human, isActive: isActive, vertical: false)
                eatenCardsView(for: human)
                if isActive {
                    Text("🎯 KARTINIZI SEÇİN")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.goldLight)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.goldDark.opacity(0.3)).cornerRadius(10)
                }
                Spacer()
                Text("Bu el: \(human.roundScore >= 0 ? "+" : "")\(human.roundScore)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(human.roundScore >= 0 ? .green : Color(red:1,green:0.3,blue:0.3))
                    .padding(.trailing, 12)
            }
            .padding(.horizontal, 12)

            PlayerHandView(
                player: human,
                validCards: validCards,
                onCardSelected: { card in gameState.playCard(card, by: human) }
            )
        }
    }
}
