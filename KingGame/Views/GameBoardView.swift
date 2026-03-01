import SwiftUI

// MARK: - Renk Paleti
extension Color {
    static let woodDark = Color(red: 0.35, green: 0.18, blue: 0.05)
    static let woodMid = Color(red: 0.55, green: 0.30, blue: 0.10)
    static let feltGreen = Color(red: 0.10, green: 0.42, blue: 0.15)
    static let feltDark = Color(red: 0.07, green: 0.30, blue: 0.10)
    static let goldLight = Color(red: 1.00, green: 0.82, blue: 0.20)
    static let goldMid = Color(red: 0.90, green: 0.65, blue: 0.10)
    static let goldDark = Color(red: 0.70, green: 0.45, blue: 0.05)
    static let plateDark = Color(red: 0.12, green: 0.12, blue: 0.12)
}

// MARK: - Oyuncu Bilgi Paneli
struct PlayerInfoPanel: View {
    let player: Player
    let isActive: Bool
    let contract: ContractType?
    var showCards: Bool = true

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            // İsim
            Text(player.name.components(separatedBy: "-").first ?? player.name)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(isActive ? Color.goldLight : .white.opacity(0.9))
                .lineLimit(1)

            // Puan satırı: toplam + el puanı
            HStack(spacing: 6) {
                Text("\(player.totalScore)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(
                        player.totalScore >= 0 ? .green : Color(red: 1, green: 0.4, blue: 0.4))
                if player.roundScore != 0 {
                    Text("(\(player.roundScore > 0 ? "+" : "")\(player.roundScore))")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(
                            player.roundScore > 0
                                ? .green.opacity(0.8) : Color(red: 1, green: 0.5, blue: 0.5))
                }
            }
        }
        .frame(width: 110, height: 65)
        .background(
            Color.white.opacity(0.05)
        )
        .background(
            // Glassmorphism effect
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive ? Color.goldLight : Color.white.opacity(0.15),
                    lineWidth: isActive ? 2 : 0.5)
        )
        .shadow(
            color: isActive ? Color.goldLight.opacity(0.3) : .black.opacity(0.5),
            radius: isActive ? 8 : 4, x: 0, y: 3)
    }
}

// MARK: - Yenilen (Ceza) Kartları Gösterimi
struct PlayerPenaltyCardsView: View {
    let player: Player
    let contract: ContractType?

    var body: some View {
        if let contract = contract {
            let penaltyCards = getPenaltyCards(for: contract)
            if !penaltyCards.isEmpty {
                HStack(spacing: 6) {  // Daha rahat boşluk
                    ForEach(penaltyCards, id: \.id) { card in
                        // Ceza Kartı Özel Görünümü (Kutu içinde büyük sembol)
                        VStack(spacing: -2) {
                            Text(card.rank.shortName)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                            Text(card.suit.symbol)
                                .font(.system(size: 18))
                        }
                        .foregroundColor(
                            card.suit.isRed ? Color(red: 1, green: 0.2, blue: 0.2) : .black
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(
                        Color.white.opacity(0.15), lineWidth: 1))
            } else if contract == .noTricks || contract == .lastTwo || contract.isTrump {
                if player.tricksWon > 0 {
                    Text("\(player.tricksWon) EL")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                        .foregroundColor(
                            contract.isTrump ? Color.goldLight : Color.white.opacity(0.8)
                        )
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(
                                Color.white.opacity(0.15), lineWidth: 1))
                }
            }
        }
    }

    private func getPenaltyCards(for contract: ContractType) -> [Card] {
        switch contract {
        case .noQueens: return player.wonCards.filter { $0.isQueen }
        case .noMales: return player.wonCards.filter { $0.isMale }
        case .noHearts: return player.wonCards.filter { $0.isHeart }
        case .rifki: return player.wonCards.filter { $0.isRifki }
        default: return []
        }
    }
}

// MARK: - GameBoardView
struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    private let dummyCard = Card(suit: .spades, rank: .two)

    func direction(for player: Player) -> TableDirection {
        guard let i = gameState.players.firstIndex(where: { $0.id == player.id }) else {
            return .south
        }
        return [TableDirection.south, .north, .west, .east][i]
    }

    func player(at dir: TableDirection) -> Player {
        switch dir {
        case .south: return gameState.players[0]
        case .north: return gameState.players[1]
        case .west: return gameState.players[2]
        case .east: return gameState.players[3]
        }
    }

    var currentContract: ContractType? {
        gameState.currentRound?.contract
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let tableW = geo.size.width - 240
            let tableH = geo.size.height - 400
            let tableX = geo.size.width / 2
            let tableY = geo.size.height / 2 - 80

            ZStack {
                // Katman 2: Masa Hattı
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .frame(width: max(tableW, 500), height: max(tableH, 300))
                    .position(x: tableX, y: tableY)

                // Katman 3: Ust bilgi bandi
                VStack {
                    topInfoBar
                    Spacer()
                }

                // Katman 4: Kuzey oyuncu
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        PlayerInfoPanel(
                            player: player(at: .north),
                            isActive: gameState.currentPlayer.id == player(at: .north).id,
                            contract: currentContract)
                        PlayerPenaltyCardsView(
                            player: player(at: .north), contract: currentContract)
                    }
                    northCards
                }
                .position(x: tableX, y: tableY - tableH / 2 + 10)

                // Katman 5: Bati oyuncu
                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        PlayerInfoPanel(
                            player: player(at: .west),
                            isActive: gameState.currentPlayer.id == player(at: .west).id,
                            contract: currentContract)
                        PlayerPenaltyCardsView(player: player(at: .west), contract: currentContract)
                    }
                    westCards
                }
                .position(x: 130, y: tableY)

                // Katman 6: Dogu oyuncu
                HStack(spacing: 12) {
                    eastCards
                    VStack(spacing: 8) {
                        PlayerInfoPanel(
                            player: player(at: .east),
                            isActive: gameState.currentPlayer.id == player(at: .east).id,
                            contract: currentContract)
                        PlayerPenaltyCardsView(player: player(at: .east), contract: currentContract)
                    }
                }
                .position(x: geo.size.width - 130, y: tableY)

                // Katman 7: Merkez — oynanan kartlar
                TrickPileView(
                    trick: gameState.currentRound?.currentTrick,
                    lastTrick: gameState.lastTrick,
                    lastTrickWinner: gameState.lastTrickWinner,
                    directionOf: { direction(for: $0) }
                )
                .position(x: tableX, y: tableY)

                // Katman 8: Guney — insan oyuncu
                VStack(spacing: 0) {
                    Spacer()
                    southZone
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(minWidth: 1050, minHeight: 780)
    }

    var topInfoBar: some View {
        HStack {
            if let round = gameState.currentRound {
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Text(round.contract.symbol)
                            .font(.system(size: 20))
                            .foregroundColor(round.contract.isTrump ? Color.goldLight : .white)
                        Text(round.contract.rawValue.uppercased())
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)

                    Text("EL \(gameState.roundNumber)/20")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))

                    // Akıllı Ceza / Durum Göstergesi
                    smartProgressIndicator(round: round)
                }
                .padding(.horizontal, 20).padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(
                        Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            }
            Spacer()
            trickCounterBar
        }
        .padding(.horizontal, 20).padding(.top, 12)
    }

    @ViewBuilder
    func smartProgressIndicator(round: Round) -> some View {
        let allWonCards =
            gameState.players.flatMap { $0.wonCards }
            + (round.currentTrick?.cards.map { $0.card } ?? [])

        switch round.contract {
        case .noHearts:
            let taken = allWonCards.filter { $0.isHeart }.count
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("♥ \(taken)/13")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(
                    taken > 0 ? Color(red: 1, green: 0.3, blue: 0.3) : .white.opacity(0.5))
        case .noQueens:
            let taken = allWonCards.filter { $0.isQueen }.count
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("KIZ: \(taken)/4")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(taken > 0 ? Color.goldMid : .white.opacity(0.5))
        case .noMales:
            let taken = allWonCards.filter { $0.isMale }.count
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("ERKEK: \(taken)/8")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(taken > 0 ? Color.blue.opacity(0.8) : .white.opacity(0.5))
        case .rifki:
            let isTaken = allWonCards.contains { $0.isRifki }
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("RIFKI: \(isTaken ? "ÇIKTI" : "BEKLENİYOR")")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(
                    isTaken ? Color(red: 1, green: 0.3, blue: 0.3) : .white.opacity(0.5))
        case .lastTwo:
            let tricksPlayed = round.tricks.count + (round.currentTrick != nil ? 1 : 0)
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("LÖVE: \(tricksPlayed)/13")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(tricksPlayed >= 12 ? Color.red : .white.opacity(0.5))
        case .noTricks:
            let tricksPlayed = round.tricks.count + (round.currentTrick != nil ? 1 : 0)
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
            Text("LÖVE: \(tricksPlayed)/13")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        default:
            if round.contract.isTrump && round.trumpOpened {
                Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
                Text("KOZ AÇIK")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color.goldLight)
            } else if round.heartsOpened {
                Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 16)
                Text("♥ AÇIK")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1, green: 0.3, blue: 0.3))
            }
        }
    }

    var trickCounterBar: some View {
        HStack(spacing: 8) {
            ForEach(gameState.players) { p in
                playerTrickCounter(for: p)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
    }

    @ViewBuilder
    private func playerTrickCounter(for p: Player) -> some View {
        let isCurrent = (gameState.currentPlayer.id == p.id)
        let namePrefix = p.name.components(separatedBy: "-").first?.prefix(3) ?? ""

        VStack(spacing: 2) {
            Text(namePrefix)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
            Text("\(p.tricksWon)")
                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                .foregroundColor(isCurrent ? Color.goldLight : .white)
        }
        .frame(width: 44, height: 42)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isCurrent ? Color.goldMid.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isCurrent ? Color.goldLight.opacity(0.8) : Color.white.opacity(0.1),
                    lineWidth: 1.5)
        )
    }

    // MARK: - KUZEY
    var northPanel: some View {
        let p = player(at: .north)
        let isActive = gameState.currentPlayer.id == p.id
        return PlayerInfoPanel(player: p, isActive: isActive, contract: currentContract)
    }

    var northCards: some View {
        let p = player(at: .north)
        return ZStack {
            ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                CardView(card: dummyCard, faceDown: true, width: 44)
                    .rotationEffect(.degrees(Double(i - p.hand.count / 2) * 2.5 + 180))
                    .offset(x: CGFloat(i - p.hand.count / 2) * 12)
            }
        }
        .frame(width: 220, height: 70)
    }

    // MARK: - BATI
    var westPanel: some View {
        let p = player(at: .west)
        let isActive = gameState.currentPlayer.id == p.id
        return PlayerInfoPanel(player: p, isActive: isActive, contract: currentContract)
    }

    var westCards: some View {
        let p = player(at: .west)
        return ZStack {
            ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                CardView(card: dummyCard, faceDown: true, width: 40)
                    .rotationEffect(.degrees(90))
                    .offset(y: CGFloat(i - p.hand.count / 2) * 10)
            }
        }
        .frame(width: 70, height: 180)
    }

    // MARK: - DOGU
    var eastPanel: some View {
        let p = player(at: .east)
        let isActive = gameState.currentPlayer.id == p.id
        return PlayerInfoPanel(player: p, isActive: isActive, contract: currentContract)
    }

    var eastCards: some View {
        let p = player(at: .east)
        return ZStack {
            ForEach(Array(0..<p.hand.count).reversed(), id: \.self) { i in
                CardView(card: dummyCard, faceDown: true, width: 40)
                    .rotationEffect(.degrees(-90))
                    .offset(y: CGFloat(i - p.hand.count / 2) * 10)
            }
        }
        .frame(width: 70, height: 180)
    }

    // MARK: - GUNEY
    var southZone: some View {
        let human = player(at: .south)
        let isActive = gameState.currentPlayer.id == human.id && gameState.phase == .playing

        let validCards: [Card] =
            isActive
            ? RuleEngine.validCards(
                for: human,
                trick: gameState.currentRound?.currentTrick,
                round: gameState.currentRound
                    ?? Round(roundNumber: 0, contract: .noTricks, contractOwner: human),
                heartsOpened: gameState.currentRound?.heartsOpened ?? false
            ) : []

        return VStack(spacing: 8) {
            // İsim paneli ve uyarıyı ortaya al
            HStack(spacing: 12) {
                Spacer()
                PlayerInfoPanel(player: human, isActive: isActive, contract: currentContract)
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

            // Kartları tutan View
            PlayerHandView(
                player: human,
                validCards: validCards,
                onCardSelected: { card in gameState.playCard(card, by: human) }
            )
            .frame(maxWidth: .infinity)  // Genişleyebildiği kadar genişlesin
        }
    }
}
