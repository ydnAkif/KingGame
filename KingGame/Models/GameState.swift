import Combine
import Foundation

enum GamePhase {
    case setup, bidding, playing, roundEnd, gameEnd
}

struct ScoreEntry: Identifiable {
    let id = UUID()
    let roundNumber: Int
    let contract: ContractType
    let contractOwner: String
    let scores: [String: Int]
    let totals: [String: Int]
}

class GameState: ObservableObject {

    // players[0]=Güney(insan) [1]=Kuzey [2]=Batı [3]=Doğu
    let players: [Player] = [
        Player(name: "Akif", type: .human),
        Player(name: "AI-Agresif", type: .aiAggressive),
        Player(name: "AI-Dengeli", type: .aiBalanced),
        Player(name: "AI-Hesapçı", type: .aiCalculator),
    ]

    @Published var phase: GamePhase = .setup
    @Published var currentRound: Round?
    @Published var completedRounds: [Round] = []
    @Published var scoreHistory: [ScoreEntry] = []
    @Published var biddingTracker = BiddingTracker()
    @Published var message: String = ""
    @Published var gameWinners: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var biddingPlayerIndex: Int = 0
    @Published var roundNumber: Int = 0

    @Published var lastTrick: Trick? = nil
    @Published var lastTrickWinner: Player? = nil

    var playedCards: [Card] = []
    private var isProcessingTrick: Bool = false

    var currentPlayer: Player { players[currentPlayerIndex] }
    var biddingPlayer: Player { players[biddingPlayerIndex] }

    // Saat yönü tersine: 0→3→1→2→0
    private let ccwNext = [3, 2, 0, 1]
    private func nextCCW(_ i: Int) -> Int { ccwNext[i] }

    // MARK: - Oyun Başlat
    func startGame() {
        completedRounds = []
        scoreHistory = []
        biddingTracker = BiddingTracker()
        roundNumber = 0
        playedCards = []
        players.forEach { $0.resetForNewGame() }
        dealCards(isFirstDeal: true)
        phase = .bidding
        message = "\(biddingPlayer.name) kontrat seçiyor..."
        scheduleAIBiddingIfNeeded()
    }

    // MARK: - Kart Dağıt
    func dealCards(isFirstDeal: Bool = false) {
        var deck = Deck()
        let hands = deck.deal()
        for (i, p) in players.enumerated() { p.hand = hands[i] }
        if isFirstDeal {
            let starter = Deck.findDiamondTwo(in: hands)
            biddingPlayerIndex = starter
            currentPlayerIndex = starter
        }
    }

    // MARK: - AI Bidding
    func scheduleAIBiddingIfNeeded() {
        guard phase == .bidding, biddingPlayer.isAI else { return }
        let idx = biddingPlayerIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self,
                self.phase == .bidding,
                self.biddingPlayerIndex == idx,
                self.biddingPlayer.isAI
            else { return }

            let available = ContractType.allCases.filter {
                RuleEngine.canSelect(
                    contract: $0,
                    player: self.biddingPlayer,
                    tracker: self.biddingTracker,
                    roundNumber: self.roundNumber + 1
                )
            }
            guard !available.isEmpty else { return }

            let chosen = AIDecisionEngine.selectContract(
                for: self.biddingPlayer,
                availableContracts: available,
                hand: self.biddingPlayer.hand,
                tracker: self.biddingTracker
            )
            self.selectContract(chosen)
        }
    }

    // MARK: - Kontrat Seç
    func selectContract(_ contract: ContractType) {
        let p = players[biddingPlayerIndex]
        biddingTracker.select(contract, for: p)
        roundNumber += 1

        currentRound = Round(
            roundNumber: roundNumber,
            contract: contract,
            contractOwner: p
        )
        players.forEach { $0.wonCards = [] }

        currentPlayerIndex = biddingPlayerIndex
        phase = .playing
        message = "\(p.name) '\(contract.rawValue)' seçti!"
        scheduleAIPlayIfNeeded()
    }

    func nextBiddingPlayer() {
        biddingPlayerIndex = nextCCW(biddingPlayerIndex)
    }

    // MARK: - Kart Oyna
    func playCard(_ card: Card, by player: Player) {
        guard phase == .playing else { return }
        guard !isProcessingTrick else { return }
        guard player.id == currentPlayer.id else { return }
        guard var round = currentRound else { return }
        guard player.playCard(card) != nil else { return }

        playedCards.append(card)

        if round.currentTrick == nil {
            round.currentTrick = Trick(
                leadSuit: card.suit,
                trickNumber: round.tricks.count + 1
            )
        }
        round.currentTrick?.cards.append((player: player, card: card))

        if card.suit == .hearts { round.heartsOpened = true }

        // Koz açıldı mı? (kozla löve kazandı)
        if let trumpSuit = round.contract.trumpSuit, card.suit == trumpSuit {
            round.trumpOpened = true
        }

        let count = round.currentTrick?.cards.count ?? 0
        print("🃏 \(player.name) → \(card.displayName) [\(count)/4]")

        // 4. kart
        if count >= 4 {
            isProcessingTrick = true
            currentRound = round

            // Eğer rıfkı atıldıysa veya oyun bitecekse daha uzun süre bekleyelim
            let willEndEarly = shouldEndEarly(round: round)
            let isRifkiContract = round.contract == .rifki
            let delay = (willEndEarly || isRifkiContract) ? 2.5 : 1.8

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.finalizeTrick(forced: false)
                self?.isProcessingTrick = false
            }
            return
        }

        currentPlayerIndex = nextCCW(currentPlayerIndex)
        currentRound = round
        message = "\(currentPlayer.name) oynuyor..."
        scheduleAIPlayIfNeeded()
    }

    // MARK: - Löveyi Kapat
    private func finalizeTrick(forced: Bool) {
        guard var round = currentRound else { return }
        guard let trick = round.currentTrick else { return }

        // Animasyon için son eli kaydet
        self.lastTrick = trick

        if let winner = trick.winner(contract: round.contract) {
            winner.winTrick()
            self.lastTrickWinner = winner

            // Kazanan kart toplar (görüntüleme için)
            winner.wonCards.append(contentsOf: trick.allCards)

            calculateScore(trick: trick, winner: winner, contract: round.contract)

            // Koz ile kazandıysa trumpOpened = true
            if let trumpSuit = round.contract.trumpSuit {
                if trick.cards.contains(where: { $0.card.suit == trumpSuit }) {
                    round.trumpOpened = true
                }
            }

            // King kontrolü
            if round.contract.isTrump && winner.tricksWon == 11 {
                round.tricks.append(trick)
                round.currentTrick = nil
                currentRound = round
                handleKing(winner: winner)
                // Animasyonu temizle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                    self?.lastTrick = nil
                    self?.lastTrickWinner = nil
                }
                return
            }

            if let idx = players.firstIndex(where: { $0.id == winner.id }) {
                currentPlayerIndex = idx
            }
            message = "\(winner.name) löveyi aldı!"
        }

        round.tricks.append(trick)
        round.currentTrick = nil
        currentRound = round

        // Animasyon bittikten sonra temizle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.lastTrick = nil
            self?.lastTrickWinner = nil
        }

        // Erken bitiş kontrolü
        if shouldEndEarly(round: round) || round.tricks.count >= 13 || forced {
            endRound(&round)
        } else {
            // Animasyon süresince (0.6) bekle, sonra AI oynasın
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.scheduleAIPlayIfNeeded()
            }
        }
    }

    // MARK: - Erken Bitiş Kontrolü
    private func shouldEndEarly(round: Round) -> Bool {
        let allWonCards = players.flatMap { $0.wonCards }
        let currentTrickCards = round.currentTrick?.cards.map { $0.card } ?? []
        let allCardsToEvaluate = allWonCards + currentTrickCards

        switch round.contract {
        case .noTricks, .lastTwo:
            // 13 löve oynanmak zorunda
            return false

        case .noHearts:
            // Tüm 13 kupa alındıysa biter, aksi halde 13 löve oynanır
            let heartsTaken = allCardsToEvaluate.filter { $0.isHeart }.count
            return heartsTaken >= 13

        case .noQueens:
            // Tüm 4 kız alındıysa biter
            let queensTaken = allCardsToEvaluate.filter { $0.isQueen }.count
            return queensTaken >= 4

        case .noMales:
            // Tüm 8 erkek (4K + 4J) alındıysa biter
            let malesTaken = allCardsToEvaluate.filter { $0.isMale }.count
            return malesTaken >= 8

        case .rifki:
            // Rıfkı alındıysa biter
            let rifkiTaken = allCardsToEvaluate.contains { $0.isRifki }
            return rifkiTaken

        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            return false
        }
    }

    // MARK: - Puan Hesapla
    private func calculateScore(trick: Trick, winner: Player, contract: ContractType) {
        switch contract {
        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            winner.roundScore += 50
        case .noTricks:
            winner.roundScore -= 50
        case .noHearts:
            winner.roundScore -= trick.allCards.filter { $0.isHeart }.count * 30
        case .noQueens:
            winner.roundScore -= trick.allCards.filter { $0.isQueen }.count * 100
        case .noMales:
            winner.roundScore -= trick.allCards.filter { $0.isMale }.count * 60
        case .lastTwo:
            if let r = currentRound, r.isLastTwo(trickNumber: trick.trickNumber) {
                winner.roundScore -= 180
            }
        case .rifki:
            if trick.containsRifki { winner.roundScore -= 320 }
        }
    }

    // MARK: - AI Oynama
    private func scheduleAIPlayIfNeeded() {
        guard phase == .playing else { return }
        guard players[currentPlayerIndex].isAI else { return }
        let idx = currentPlayerIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self,
                self.phase == .playing,
                self.currentPlayerIndex == idx,
                self.players[idx].isAI
            else { return }
            self.performAIPlay(self.players[idx])
        }
    }

    private func performAIPlay(_ player: Player) {
        guard let round = currentRound, player.id == currentPlayer.id else { return }
        let valid = RuleEngine.validCards(
            for: player,
            trick: round.currentTrick,
            round: round,
            heartsOpened: round.heartsOpened
        )
        guard !valid.isEmpty else { return }
        let card = AIDecisionEngine.selectCard(
            for: player,
            validCards: valid,
            trick: round.currentTrick,
            round: round,
            allPlayers: players,
            playedCards: playedCards
        )
        playCard(card, by: player)
    }

    // MARK: - Kontrat Bitir
    private func endRound(_ round: inout Round) {
        round.isComplete = true
        players.forEach { $0.totalScore += $0.roundScore }

        scoreHistory.append(
            ScoreEntry(
                roundNumber: round.roundNumber,
                contract: round.contract,
                contractOwner: round.contractOwner.name,
                scores: Dictionary(uniqueKeysWithValues: players.map { ($0.name, $0.roundScore) }),
                totals: Dictionary(uniqueKeysWithValues: players.map { ($0.name, $0.totalScore) })
            ))
        completedRounds.append(round)
        currentRound = round

        if roundNumber >= 20 {
            endGame()
        } else {
            phase = .roundEnd
        }
    }

    func startNextRound() {
        players.forEach { $0.resetForNewRound() }
        nextBiddingPlayer()
        dealCards()
        currentPlayerIndex = biddingPlayerIndex
        phase = .bidding
        message = "\(biddingPlayer.name) kontrat seçiyor..."
        scheduleAIBiddingIfNeeded()
    }

    // MARK: - King
    private func handleKing(winner: Player) {
        message = "👑 KİNG! \(winner.name) 11 löve aldı!"
        // King'de normal koz puanları iptal, sadece +12 / -4 uygulanır
        players.forEach { $0.roundScore = 0 }
        winner.totalScore += 12
        players.filter { $0.id != winner.id }.forEach { $0.totalScore -= 4 }

        scoreHistory.append(
            ScoreEntry(
                roundNumber: roundNumber,
                contract: currentRound?.contract ?? .trumpSpades,
                contractOwner: currentRound?.contractOwner.name ?? winner.name,
                scores: Dictionary(
                    uniqueKeysWithValues: players.map {
                        ($0.name, $0.id == winner.id ? 12 : -4)
                    }),
                totals: Dictionary(uniqueKeysWithValues: players.map { ($0.name, $0.totalScore) })
            ))

        phase = .gameEnd
        determineWinners()
    }

    private func endGame() {
        phase = .gameEnd
        determineWinners()
    }

    private func determineWinners() {
        let maxScore = players.map { $0.totalScore }.max() ?? 0
        let winners = players.filter { $0.totalScore >= 0 }
        gameWinners = winners.isEmpty ? players.filter { $0.totalScore == maxScore } : winners
        let winnerIDs = Set(gameWinners.map { $0.id })
        let losers = players.filter { !winnerIDs.contains($0.id) }
        gameWinners.forEach { $0.totalScore += 12 / max(gameWinners.count, 1) }
        losers.forEach { $0.totalScore -= 12 / max(losers.count, 1) }
        gameWinners.max(by: { $0.totalScore < $1.totalScore })?.totalScore += 3
        message = "Oyun bitti! Kazananlar: \(gameWinners.map { $0.name }.joined(separator: ", "))"
    }
}
