import AVFoundation
import Combine
import Foundation

#if os(macOS)
    import AppKit
#endif

// MARK: - Sound Types

/// Defines all sound effects in the game.
enum SoundType: String, CaseIterable {
    case cardPlay = "card_play"
    /// Card played on table
    case trickWin = "trick_win"
    /// Won a trick
    case bidding = "bidding"
    /// Contract selected
    case king = "king"
    /// King achievement
    case error = "error"
    /// Invalid move
    case shuffle = "shuffle"
    /// Cards shuffling
    case deal = "deal"
    /// Cards dealing
    case roundEnd = "round_end"
    /// Round completed
    case gameEnd = "game_end"
    /// Game completed

    /// File extension for this sound
    var fileExtension: String {
        return "wav"
    }
}

// MARK: - Audio Manager

/// Manages all audio playback in the game.
///
/// `AudioManager` is a singleton that handles:
/// - Sound effect playback
/// - Volume control
/// - Mute functionality
/// - Sound preloading
///
/// ## Usage
/// ```swift
/// AudioManager.shared.play(.cardPlay)
/// AudioManager.shared.isMuted = true
/// AudioManager.shared.volume = 0.5
/// ```
///
/// - Note: Sounds are loaded from the app bundle's Audio folder.
/// - Important: Call `preloadSounds()` at app launch for instant playback.
class AudioManager: ObservableObject {

    static var isTesting: Bool = (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil)

    // MARK: - Singleton

    /// Shared audio manager instance
    static let shared = AudioManager()

    // MARK: - Published Properties

    /// Whether all sounds are muted
    @Published var isMuted: Bool = false {
        didSet {
            if isMuted {
                stopAllSounds()
            }
        }
    }

    /// Master volume (0.0 to 1.0)
    @Published var volume: Float = 0.7 {
        didSet {
            volume = max(0.0, min(1.0, volume))
        }
    }

    /// Whether sound effects are enabled
    @Published var isSoundEnabled: Bool = true

    // MARK: - Private Properties

    /// Audio player cache for quick playback
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]

    /// Currently playing sounds
    private var activePlayers: Set<AVAudioPlayer> = []

    // MARK: - Initialization

    private init() {
        if !AudioManager.isTesting { preloadSounds() }
    }

    // MARK: - Public Methods

    /// Plays a sound effect.
    /// - Parameter sound: The sound type to play
    /// - Returns: `true` if sound started playing, `false` if muted or unavailable
    @discardableResult
    func play(_ sound: SoundType) -> Bool {
        if AudioManager.isTesting { return false }
        guard !isMuted, isSoundEnabled else { return false }

        if let player = audioPlayers[sound] {
            player.currentTime = 0
            player.volume = volume
            let success = player.play()
            if success {
                activePlayers.insert(player)
            }
            return success
        } else {
            // Try to load and play
            loadSound(sound)
            return play(sound)
        }
    }

    /// Stops all currently playing sounds.
    func stopAllSounds() {
        for player in activePlayers {
            player.stop()
        }
        activePlayers.removeAll()
    }

    /// Stops a specific sound type.
    /// - Parameter sound: The sound type to stop
    func stop(_ sound: SoundType) {
        if let player = audioPlayers[sound] {
            player.stop()
            activePlayers.remove(player)
        }
    }

    /// Preloads all sounds for instant playback.
    ///
    /// Call this at app launch to avoid loading delays during gameplay.
    func preloadSounds() {
        for sound in SoundType.allCases {
            loadSound(sound)
        }
        print("🔊 AudioManager: Preloaded \(audioPlayers.count) sounds")
    }

    /// Cleans up unused audio players to free memory.
    func cleanup() {
        activePlayers = activePlayers.filter { $0.isPlaying }
    }

    // MARK: - Private Methods

    /// Loads a sound from the bundle.
    /// - Parameter sound: The sound type to load
    private func loadSound(_ sound: SoundType) {
        guard !AudioManager.isTesting else { return }
        guard audioPlayers[sound] == nil else { return }

        if let url = Bundle.main.url(
            forResource: sound.rawValue, withExtension: sound.fileExtension)
        {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[sound] = player
            } catch {
                print("⚠️ AudioManager: Failed to load sound \(sound.rawValue): \(error)")
            }
        } else {
            // Sound file not found - this is OK for development
        }
    }

    /// Generates a simple beep sound programmatically (fallback).
    func playBeep() {
        guard !isMuted, isSoundEnabled else { return }

        // System beep (macOS)
        #if os(macOS)
            let beep = NSSound(named: NSSound.Name("Pop"))
            beep?.play()
        #endif
    }
}

// MARK: - Convenience Extensions

extension AudioManager {
    /// Play card play sound
    func playCardSound() {
        play(.cardPlay)
    }

    /// Play trick win sound
    func playTrickWinSound() {
        play(.trickWin)
    }

    /// Play king achievement sound
    func playKingSound() {
        play(.king)
    }

    /// Play error sound for invalid moves
    func playErrorSound() {
        play(.error)
    }
}

