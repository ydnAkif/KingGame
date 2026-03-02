import Combine
import Foundation

// MARK: - Game Phase

/// Represents the current phase of the game.
///
/// The game progresses through these phases in order:
/// 1. `setup` - Initial state before game starts
/// 2. `bidding` - Players select contracts
/// 3. `playing` - Cards are being played
/// 4. `roundEnd` - Round completed, showing scores
/// 5. `gameEnd` - All 20 rounds completed
enum GamePhase {
    case setup
    case bidding
    case playing
    case roundEnd
    case gameEnd
}

/// Represents a single score entry for a completed round.
///
/// Used to track the scoring history throughout the game.
struct ScoreEntry: Identifiable {
    let id = UUID()
    let roundNumber: Int
    let contract: ContractType
    let contractOwner: String
    let scores: [String: Int]
    let totals: [String: Int]
}

/// Main game controller managing the entire game lifecycle.
///
/// `GameState` is the central observable object that coordinates:
/// - Player management (4 players: 1 human + 3 AI)
/// - Card dealing and trick tracking
/// - Bidding and contract selection
/// - Score calculation and round management
/// - Game phase transitions
///
/// ## Game Flow
/// 1. `startGame()` - Initialize 20-round game
/// 2. Bidding phase - Diamond 2 owner bids first
/// 3. Playing phase - 13 tricks per round
/// 4. Round end - Score summary
/// 5. Repeat until 20 rounds complete
///
/// ## Player Order
/// Players are indexed as: [0]South(human) [1]North [2]West [3]East
/// Turn order is counter-clockwise: South → East → North → West
///
/// - Note: This class uses `@Published` properties for SwiftUI reactivity.
class GameState: ObservableObject {

    // Player order: South (human), North, West, East
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
    @Published private var isProcessingTrick: Bool = false

    var currentPlayer: Player { players[currentPlayerIndex] }
    var biddingPlayer: Player { players[biddingPlayerIndex] }

    // Counter-clockwise index progression: 0→3→1→2→0
    private let ccwNext = [3, 2, 0, 1]
    private func nextCCW(_ i: Int) -> Int { ccwNext[i] }

    // MARK: - Game Start
    func startGame() {
        completedRounds = []
        scoreHistory = []
        biddingTracker = BiddingTracker()
        roundNumber = 0
        currentPlayerIndex = 0
        biddingPlayerIndex = 0
        playedCards = []
        players.forEach { $0.resetForNewGame() }
        dealCards(isFirstDeal: true)
        phase = .bidding
        message = "\(biddingPlayer.name) kontrat seçiyor..."
        scheduleAIBiddingIfNeeded()
    }

    // MARK: - Card Dealing
    func dealCards(isFirstDeal: Bool = false) {
        var deck = Deck()
        let hands = deck.deal()
        for (i, p) in players.enumerated() { p.hand = hands[i] }
        if isFirstDeal {
            if let starter = Deck.findDiamondTwo(in: hands) {
                biddingPlayerIndex = starter
                currentPlayerIndex = starter
            } else {
                biddingPlayerIndex = 0
                currentPlayerIndex = 0
            }
        }
    }

    // MARK: - AI Bidding
    func scheduleAIBiddingIfNeeded() {
        guard phase == .bidding, biddingPlayer.isAI else { return }
        let idx = biddingPlayerIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.aiBiddingDelay) {
            [weak self] in
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
                tracker: self.biddingTracker,
                roundNumber: self.roundNumber + 1
            )
            self.selectContract(chosen)
        }
    }

    // MARK: - Contract Selection
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

        // Reset played cards when a contract is selected for the new round
        playedCards = []

        currentPlayerIndex = biddingPlayerIndex
        phase = .playing
        message = "\(p.name) '\(contract.rawValue)' seçti!"
        scheduleAIPlayIfNeeded()
    }

    func nextBiddingPlayer() {
        biddingPlayerIndex = nextCCW(biddingPlayerIndex)
    }

    // MARK: - Playing a Card
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

        let count = round.currentTrick?.cards.count ?? 0
        print("🃏 \(player.name) → \(card.displayName) [\(count)/4]")

        // Fourth card in the trick
        if count >= 4 {
            isProcessingTrick = true
            currentRound = round

            // Delay longer if Rifki is played or the round could end soon
            let willEndEarly = shouldEndEarly(round: round)
            let isRifkiContract = round.contract == .rifki
            let delay =
                (willEndEarly || isRifkiContract)
                ? GameConstants.trickGatherDelayExtended : GameConstants.trickGatherDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.finalizeTrick(forced: false)
            }
            return
        }

        currentPlayerIndex = nextCCW(currentPlayerIndex)
        currentRound = round
        message = "\(currentPlayer.name) oynuyor..."
        scheduleAIPlayIfNeeded()
    }

    // MARK: - Finalizing Trick
    private func finalizeTrick(forced: Bool) {
        defer { isProcessingTrick = false }

        guard var round = currentRound else { return }
        guard let trick = round.currentTrick else { return }

        // Store the last trick for animations
        self.lastTrick = trick

        if let winner = trick.winner(contract: round.contract) {
            winner.winTrick()
            self.lastTrickWinner = winner

            // Winner collects cards for display
            winner.wonCards.append(contentsOf: trick.allCards)

            calculateScore(trick: trick, winner: winner, contract: round.contract)

            // If a trump card appeared, flag that trump has opened
            if let trumpSuit = round.contract.trumpSuit {
                if trick.cards.contains(where: { $0.card.suit == trumpSuit }) {
                    round.trumpOpened = true
                }
            }

            // Check for King condition
            if round.contract.isTrump && winner.tricksWon == 11 {
                round.tricks.append(trick)
                round.currentTrick = nil
                currentRound = round
                handleKing(winner: winner)
                // Clear animation state
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

        // Clean up animation state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.cardPlayAnimationDuration) {
            [weak self] in
            self?.lastTrick = nil
            self?.lastTrickWinner = nil
        }

        // Check for early round termination
        if shouldEndEarly(round: round) || round.tricks.count >= 13 || forced {
            endRound(&round)
        } else {
            // Wait for animation before letting AI continue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.scheduleAIPlayIfNeeded()
            }
        }
    }

    // MARK: - Early Round End Check
    private func shouldEndEarly(round: Round) -> Bool {
        let allWonCards = players.flatMap { $0.wonCards }
        let currentTrickCards = round.currentTrick?.cards.map { $0.card } ?? []
        let allCardsToEvaluate = allWonCards + currentTrickCards

        switch round.contract {
        case .noTricks, .lastTwo:
            // Always play all 13 tricks for these contracts
            return false

        case .noHearts:
            // End once all 13 hearts have been captured
            let heartsTaken = allCardsToEvaluate.filter { $0.isHeart }.count
            return heartsTaken >= 13

        case .noQueens:
            // End once all 4 queens have been captured
            let queensTaken = allCardsToEvaluate.filter { $0.isQueen }.count
            return queensTaken >= 4

        case .noMales:
            // End once all 8 male cards (kings and jacks) have been captured
            let malesTaken = allCardsToEvaluate.filter { $0.isMale }.count
            return malesTaken >= 8

        case .rifki:
            // End once the Rifki (King of Hearts) has been captured
            let rifkiTaken = allCardsToEvaluate.contains { $0.isRifki }
            return rifkiTaken

        case .trumpSpades, .trumpHearts, .trumpDiamonds, .trumpClubs:
            return false
        }
    }

    // MARK: - Score Calculation
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

    // MARK: - AI Play Scheduling
    private func scheduleAIPlayIfNeeded() {
        guard phase == .playing else { return }
        guard players[currentPlayerIndex].isAI else { return }
        let idx = currentPlayerIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.aiPlayDelay) { [weak self] in
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

    // MARK: - Round End Management
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

        // Clear played cards when starting the next round
        playedCards = []

        currentPlayerIndex = biddingPlayerIndex
        phase = .bidding
        message = "\(biddingPlayer.name) kontrat seçiyor..."
        scheduleAIBiddingIfNeeded()
    }

    // MARK: - King
    private func handleKing(winner: Player) {
        message = "👑 KİNG! \(winner.name) 11 löve aldı!"
        // King overrides regular trump scoring with fixed bonuses/penalties
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
        gameWinners = players.filter { $0.totalScore >= 0 }
        if gameWinners.isEmpty {
            gameWinners = players.filter { $0.totalScore == maxScore }
        }
        message = "Oyun bitti! Kazananlar: \(gameWinners.map { $0.name }.joined(separator: ", "))"
    }

    // MARK: - Test Helpers (DEBUG only)
    #if DEBUG
        /// Exposed for unit testing - checks if round should end early
        func shouldEndEarlyForTest(round: Round) -> Bool {
            return shouldEndEarly(round: round)
        }

        /// Exposed for unit testing - determines winners
        func determineWinnersForTest() {
            determineWinners()
        }
    #endif
}
