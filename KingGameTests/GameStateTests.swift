import XCTest

@testable import KingGame

// MARK: - GameState Tests
final class GameStateTests: XCTestCase {

    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameState = GameState()
    }

    override func tearDown() {
        gameState = nil
        super.tearDown()
    }

    func testGameStateInitialization() {
        XCTAssertEqual(gameState.phase, .setup)
        XCTAssertEqual(gameState.players.count, 4)
        XCTAssertEqual(gameState.scoreHistory.count, 0)
        XCTAssertEqual(gameState.roundNumber, 0)
    }

    func testGameStatePlayerOrder() {
        // South (human), North, West, East
        XCTAssertEqual(gameState.players[0].name, "Akif")
        XCTAssertEqual(gameState.players[0].type, .human)

        XCTAssertTrue(gameState.players[1].isAI)
        XCTAssertTrue(gameState.players[2].isAI)
        XCTAssertTrue(gameState.players[3].isAI)
    }

    func testStartGame() {
        gameState.startGame()

        XCTAssertEqual(gameState.phase, .bidding)
        XCTAssertGreaterThan(gameState.roundNumber, 0)

        // All players should have 13 cards
        for player in gameState.players {
            XCTAssertEqual(player.hand.count, 13)
        }
    }

    func testStartGameResetsState() {
        // Modify some state
        gameState.roundNumber = 10

        gameState.startGame()

        XCTAssertEqual(gameState.roundNumber, 1)
        XCTAssertEqual(gameState.scoreHistory.count, 0)
        XCTAssertEqual(gameState.completedRounds.count, 0)
    }

    func testStartGameFindsDiamondTwo() {
        gameState.startGame()

        // Find which player has diamond two
        var diamondTwoOwner: Int?
        for (index, player) in gameState.players.enumerated() {
            if player.hand.contains(where: { $0.suit == .diamonds && $0.rank == .two }) {
                diamondTwoOwner = index
                break
            }
        }

        XCTAssertNotNil(diamondTwoOwner)
        XCTAssertEqual(gameState.biddingPlayerIndex, diamondTwoOwner)
    }

    func testCurrentPlayer() {
        gameState.startGame()

        let currentPlayer = gameState.currentPlayer
        XCTAssertEqual(currentPlayer, gameState.players[gameState.currentPlayerIndex])
    }

    func testBiddingPlayer() {
        gameState.startGame()

        let biddingPlayer = gameState.biddingPlayer
        XCTAssertEqual(biddingPlayer, gameState.players[gameState.biddingPlayerIndex])
    }

    func testSelectContract() {
        gameState.startGame()

        let initialRoundNumber = gameState.roundNumber
        let contract = ContractType.noTricks

        gameState.selectContract(contract)

        XCTAssertEqual(gameState.phase, .playing)
        XCTAssertEqual(gameState.roundNumber, initialRoundNumber + 1)
        XCTAssertNotNil(gameState.currentRound)
        XCTAssertEqual(gameState.currentRound?.contract, contract)
    }

    func testSelectContractResetsWonCards() {
        gameState.startGame()

        // Manually add wonCards to test reset
        for player in gameState.players {
            player.wonCards = [Card(suit: .hearts, rank: .ace)]
        }

        gameState.selectContract(.noTricks)

        for player in gameState.players {
            XCTAssertEqual(player.wonCards.count, 0)
        }
    }

    func testSelectContractResetsPlayedCards() {
        gameState.startGame()

        // This would normally be populated during play
        gameState.playedCards = [Card(suit: .spades, rank: .ace)]

        gameState.selectContract(.noTricks)

        XCTAssertEqual(gameState.playedCards.count, 0)
    }

    func testNextBiddingPlayer() {
        gameState.startGame()
        let initialIndex = gameState.biddingPlayerIndex

        gameState.nextBiddingPlayer()

        // Counter-clockwise: 0→3→1→2→0
        let expectedIndex = gameState.players.count - 1
        XCTAssertEqual(gameState.biddingPlayerIndex, expectedIndex)
    }

    func testShouldEndEarlyNoTricks() {
        gameState.startGame()
        gameState.selectContract(.noTricks)

        // noTricks and lastTwo always play all 13 tricks
        let round = gameState.currentRound!
        XCTAssertFalse(gameState.shouldEndEarlyForTest(round: round))
    }

    func testShouldEndEarlyNoHearts() {
        gameState.startGame()
        gameState.selectContract(.noHearts)

        // Simulate all 13 hearts captured
        for player in gameState.players {
            player.wonCards = [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .hearts, rank: .king),
                Card(suit: .hearts, rank: .queen),
                Card(suit: .hearts, rank: .jack),
            ]
        }

        let round = gameState.currentRound!
        XCTAssertTrue(gameState.shouldEndEarlyForTest(round: round))
    }

    func testShouldEndEarlyNoQueens() {
        gameState.startGame()
        gameState.selectContract(.noQueens)

        // Simulate all 4 queens captured
        for player in gameState.players {
            player.wonCards = [
                Card(suit: .spades, rank: .queen),
                Card(suit: .hearts, rank: .queen),
            ]
        }

        let round = gameState.currentRound!
        XCTAssertTrue(gameState.shouldEndEarlyForTest(round: round))
    }

    func testShouldEndEarlyNoMales() {
        gameState.startGame()
        gameState.selectContract(.noMales)

        // Simulate 8 male cards captured
        for player in gameState.players {
            player.wonCards = [
                Card(suit: .spades, rank: .king),
                Card(suit: .hearts, rank: .king),
                Card(suit: .diamonds, rank: .jack),
                Card(suit: .clubs, rank: .jack),
            ]
        }

        let round = gameState.currentRound!
        XCTAssertTrue(gameState.shouldEndEarlyForTest(round: round))
    }

    func testShouldEndEarlyRifki() {
        gameState.startGame()
        gameState.selectContract(.rifki)

        // Simulate Rifki captured
        let player = gameState.players[0]
        player.wonCards = [Card(suit: .hearts, rank: .king)]

        let round = gameState.currentRound!
        XCTAssertTrue(gameState.shouldEndEarlyForTest(round: round))
    }

    func testStartNextRound() {
        gameState.startGame()
        gameState.selectContract(.noTricks)

        let initialRoundNumber = gameState.roundNumber

        gameState.startNextRound()

        XCTAssertEqual(gameState.phase, .bidding)
        XCTAssertEqual(gameState.roundNumber, initialRoundNumber + 1)
    }

    func testStartNextRoundResetsPlayers() {
        gameState.startGame()
        gameState.selectContract(.noTricks)

        // Modify player state
        for player in gameState.players {
            player.tricksWon = 5
            player.roundScore = 100
        }

        gameState.startNextRound()

        for player in gameState.players {
            XCTAssertEqual(player.tricksWon, 0)
            XCTAssertEqual(player.roundScore, 0)
        }
    }

    func testDetermineWinners() {
        gameState.startGame()

        // Set up scores
        gameState.players[0].totalScore = 100
        gameState.players[1].totalScore = 50
        gameState.players[2].totalScore = -20
        gameState.players[3].totalScore = -50

        gameState.determineWinnersForTest()

        // Players with positive scores should be winners
        let winners = gameState.gameWinners
        XCTAssertTrue(winners.contains(gameState.players[0]))
        XCTAssertTrue(winners.contains(gameState.players[1]))
    }

    func testDetermineWinnersAllNegative() {
        gameState.startGame()

        // All negative scores
        gameState.players[0].totalScore = -10
        gameState.players[1].totalScore = -20
        gameState.players[2].totalScore = -30
        gameState.players[3].totalScore = -40

        gameState.determineWinnersForTest()

        // Highest score (least negative) should win
        let winners = gameState.gameWinners
        XCTAssertEqual(winners.count, 1)
        XCTAssertEqual(winners[0], gameState.players[0])
    }
}
