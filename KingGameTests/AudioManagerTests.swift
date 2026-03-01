import XCTest

@testable import KingGame

// MARK: - AudioManager Tests (Mock)
final class AudioManagerTests: XCTestCase {

    var audioManager: AudioManager!

    override func setUp() {
        super.setUp()
        audioManager = AudioManager.shared
    }

    override func tearDown() {
        audioManager = nil
        super.tearDown()
    }

    func testSingletonInstance() {
        let instance1 = AudioManager.shared
        let instance2 = AudioManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    func testInitialVolume() {
        XCTAssertEqual(audioManager.volume, 0.7)
    }

    func testVolumeRange() {
        audioManager.volume = -0.5
        XCTAssertEqual(audioManager.volume, 0.0)

        audioManager.volume = 1.5
        XCTAssertEqual(audioManager.volume, 1.0)

        audioManager.volume = 0.5
        XCTAssertEqual(audioManager.volume, 0.5)
    }

    func testMuteToggle() {
        audioManager.isMuted = false
        audioManager.isMuted = true
        XCTAssertTrue(audioManager.isMuted)

        audioManager.isMuted = false
        XCTAssertFalse(audioManager.isMuted)
    }

    func testSoundEnabledToggle() {
        audioManager.isSoundEnabled = true
        XCTAssertTrue(audioManager.isSoundEnabled)

        audioManager.isSoundEnabled = false
        XCTAssertFalse(audioManager.isSoundEnabled)
    }

    func testSoundTypeCount() {
        XCTAssertEqual(SoundType.allCases.count, 9)
    }

    func testSoundTypeFileExtension() {
        for sound in SoundType.allCases {
            XCTAssertEqual(sound.fileExtension, "wav")
        }
    }

    func testSoundTypeRawValues() {
        XCTAssertEqual(SoundType.cardPlay.rawValue, "card_play")
        XCTAssertEqual(SoundType.trickWin.rawValue, "trick_win")
        XCTAssertEqual(SoundType.bidding.rawValue, "bidding")
        XCTAssertEqual(SoundType.king.rawValue, "king")
        XCTAssertEqual(SoundType.error.rawValue, "error")
        XCTAssertEqual(SoundType.shuffle.rawValue, "shuffle")
        XCTAssertEqual(SoundType.deal.rawValue, "deal")
        XCTAssertEqual(SoundType.roundEnd.rawValue, "round_end")
        XCTAssertEqual(SoundType.gameEnd.rawValue, "game_end")
    }

    func testPlayWhenMuted() {
        audioManager.isMuted = true
        // Should return false when muted
        // Note: Actual playback depends on file availability
        let result = audioManager.play(.cardPlay)
        XCTAssertFalse(result)
    }

    func testPlayWhenSoundDisabled() {
        audioManager.isMuted = false
        audioManager.isSoundEnabled = false
        let result = audioManager.play(.cardPlay)
        XCTAssertFalse(result)
    }

    func testStopAllSounds() {
        // Should not crash
        audioManager.stopAllSounds()
    }

    func testStopSpecificSound() {
        // Should not crash
        audioManager.stop(.cardPlay)
    }

    func testCleanup() {
        // Should not crash
        audioManager.cleanup()
    }

    func testConvenienceMethods() {
        // These should not crash
        audioManager.isMuted = true  // Prevent actual playback

        audioManager.playCardSound()
        audioManager.playTrickWinSound()
        audioManager.playKingSound()
        audioManager.playErrorSound()
    }
}

// MARK: - CardCountTracker Tests
final class CardCountTrackerTests: XCTestCase {

    func testTrackerInitialization() {
        let tracker = CardCountTracker()
        // Should initialize without error
        XCTAssertNotNil(tracker.remainingCards)
    }

    func testRecordPlayedCard() {
        var tracker = CardCountTracker()
        let card = Card(suit: .hearts, rank: .ace)

        tracker.recordPlayedCard(card, trickNumber: 1)

        // Card is recorded internally
        XCTAssertTrue(true)  // Basic test - tracker doesn't crash
    }

    func testRemainingCount() {
        let tracker = CardCountTracker()
        let knownCards = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .queen),
        ]

        let heartsRemaining = tracker.remainingCount(in: .hearts, knownCards: knownCards)
        XCTAssertEqual(heartsRemaining, 11)  // 13 - 2

        let spadesRemaining = tracker.remainingCount(in: .spades, knownCards: knownCards)
        XCTAssertEqual(spadesRemaining, 12)  // 13 - 1

        let diamondsRemaining = tracker.remainingCount(in: .diamonds, knownCards: knownCards)
        XCTAssertEqual(diamondsRemaining, 13)  // 13 - 0
    }

    func testIsSuitVoid() {
        let tracker = CardCountTracker()

        // With no known cards, suit is not void
        XCTAssertFalse(tracker.isSuitVoid(.hearts, knownCards: []))

        // With 13 known cards in suit, should be void
        let thirteenHearts = (0..<13).map { i in
            Card(suit: .hearts, rank: Rank.allCases[i])
        }
        XCTAssertTrue(tracker.isSuitVoid(.hearts, knownCards: thirteenHearts))
    }

    func testMultipleRecordings() {
        var tracker = CardCountTracker()

        let cards = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .queen),
        ]

        for (index, card) in cards.enumerated() {
            tracker.recordPlayedCard(card, trickNumber: index + 1)
        }

        // Should not crash with multiple recordings
        XCTAssertTrue(true)
    }
}
