# 👑 King Game

[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Test Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)]()

A premium macOS card game built with SwiftUI featuring the traditional Turkish King card game with modern UI/UX.

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Game Rules](#-game-rules)
- [Architecture](#-architecture)
- [Testing](#-testing)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## 🎮 Overview

**King** is a traditional Turkish trick-avoidance card game played with 52 cards by 4 players. This implementation brings the classic game to macOS with:

- 🎨 **Premium UI/UX** - Glassmorphism effects, smooth animations, and elegant design
- 🤖 **Smart AI** - Three AI personalities (Aggressive, Balanced, Calculator)
- 📱 **Native macOS** - Built with SwiftUI for optimal performance
- 🎯 **Complete Rules** - All 6 penalty and 4 trump contracts implemented

---

## ✨ Features

### Game Mechanics
- ✅ 52-card deck, 4 players, 20 rounds
- ✅ 6 penalty contracts: El Almaz, Kupa Almaz, Kız Almaz, Erkek Almaz, Son İki, Rıfkı
- ✅ 4 trump contracts: ♠ Maça, ♥ Kupa, ♦ Karo, ♣ Sinek
- ✅ Counter-clockwise turn order: South → East → North → West
- ✅ Diamond 2 determines first bidder
- ✅ Early round termination for specific contracts
- ✅ King achievement (11 tricks in trump) ends game instantly

### AI System
- 🤖 **Aggressive AI** - High risk tolerance (35%), prefers high trumps
- ⚖️ **Balanced AI** - Medium risk (50%), optimal contract selection
- 🧮 **Calculator AI** - Low risk (25%), card counting, safe plays

### UI/UX
- 🎨 Glassmorphism effects with `.ultraThinMaterial`
- 🃏 Mac Dock-style card hover animations
- ✨ Smooth card dealing and trick gathering animations
- 📊 Smart HUD with real-time penalty tracking
- 🌙 Premium dark casino theme with gold accents
- 🎯 Interactive card selection with visual feedback

---

## 📸 Screenshots

| Main Menu | Game Board | Bidding |
|-----------|------------|---------|
| ![Menu](Screenshots/menu.png) | ![Board](Screenshots/board.png) | ![Bidding](Screenshots/bidding.png) |

---

## 🛠 Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

---

## 📥 Installation

### Clone the Repository
```bash
git clone https://github.com/yourusername/KingGame.git
cd KingGame
```

### Open in Xcode
```bash
open KingGame.xcodeproj
```

### Build and Run
- Press `Cmd + R` in Xcode
- Or build from command line:
```bash
xcodebuild -project KingGame.xcodeproj -scheme KingGame build
```

---

## 📜 Game Rules

### Contract Types

#### Penalty Contracts (Ceza)
| Contract | Turkish | Penalty | Special Rule |
|----------|---------|---------|--------------|
| El Almaz | No Tricks | -50 per trick | Always 13 tricks |
| Kupa Almaz | No Hearts | -30 per ♥ | Can't lead ♥ until opened |
| Kız Almaz | No Queens | -100 per Q | Must play Q if A/K on table |
| Erkek Almaz | No Males | -60 per K/J | — |
| Son İki | Last Two | -180 on tricks 12&13 | Always 13 tricks |
| Rıfkı | Rifki | -320 for ♥K | Ends when ♥K captured |

#### Trump Contracts (Koz)
| Contract | Trump Suit | Score |
|----------|-----------|-------|
| Maça Koz | ♠ Spades | +50 per trick |
| Kupa Koz | ♥ Hearts | +50 per trick |
| Karo Koz | ♦ Diamonds | +50 per trick |
| Sinek Koz | ♣ Clubs | +50 per trick |

### Bidding Rules
1. **First 4 rounds**: Only penalty contracts allowed
2. **Per player limits**: Max 2 trumps + max 3 penalties
3. **Global limits**: Each penalty type max 2 times per game
4. **Diamond 2 owner**: Bids first in the game

### King Achievement
- **Condition**: Win 11 tricks in a trump contract
- **Result**: Game ends immediately
- **Scoring**: Winner +12, others -4 each

### End Game Scoring
- Winners (positive score): +12 bonus
- Best winner: +3 additional bonus
- Losers: -12 penalty divided among them

---

## 🏗 Architecture

### Models
```
Models/
├── Card.swift          # Card, Suit, Rank models
├── Deck.swift          # 52-card deck, shuffling, dealing
├── Player.swift        # Human + AI players
├── ContractType.swift  # 10 contract types + BiddingTracker
├── Trick.swift         # Single trick logic
├── Round.swift         # 13-trick round management
└── GameState.swift     # Main game controller
```

### Engine
```
Engine/
├── RuleEngine.swift         # Card validity rules
└── AIDecisionEngine.swift   # AI decision making
```

### Views
```
Views/
├── CardView.swift        # Individual card display
├── PlayerHandView.swift  # Human hand with hover effects
├── TrickPileView.swift   # Cards on table
├── BiddingView.swift     # Contract selection
├── GameBoardView.swift   # Main game board
├── MainMenuView.swift    # Start screen
├── RoundEndView.swift    # Round summary
└── GameEndView.swift     # Final results
```

### Design Patterns
- **ObservableObject + @Published**: Reactive state management
- **MVVM-inspired**: Separation of game logic and UI
- **Strategy Pattern**: AI decision making
- **State Machine**: Game phase transitions

---

## 🧪 Testing

### Run Tests
```bash
xcodebuild test -project KingGame.xcodeproj -scheme KingGame -destination 'platform=macOS'
```

### Test Coverage
- ✅ Card model tests (15 tests)
- ✅ Deck model tests (12 tests)
- ✅ Player model tests (14 tests)
- ✅ ContractType tests (12 tests)
- ✅ Trick & Round tests (10 tests)
- ✅ RuleEngine tests (12 tests)
- ✅ AIDecisionEngine tests (11 tests)
- ✅ GameState tests (15 tests)

**Total: 100+ unit tests**

### Test Files
```
KingGameTests/
├── CardTests.swift
├── DeckTests.swift
├── PlayerTests.swift
├── ContractTypeTests.swift
├── TrickTests.swift
├── RuleEngineTests.swift
├── AIDecisionEngineTests.swift
└── GameStateTests.swift
```

---

## 📁 Project Structure

```
KingGame/
├── KingGame/
│   ├── Models/           # Data models
│   ├── Engine/           # Game logic
│   ├── Views/            # SwiftUI views
│   ├── Utils/            # Constants & utilities
│   ├── Assets.xcassets/  # Images & colors
│   └── Audio/            # Sound files (future)
├── KingGameTests/        # Unit tests
├── .swiftlint.yml        # Code style rules
├── README.md             # This file
├── LICENSE               # MIT License
└── KingGame.xcodeproj    # Xcode project
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- SwiftLint rules enforced
- Follow Swift API Design Guidelines
- Write tests for new features
- Document public APIs

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Assets
- **Card SVGs**: [htdebeer/SVG-cards](https://github.com/htdebeer/SVG-cards) (LGPL License)

---

## 🙏 Acknowledgments

- **Game Design**: Traditional Turkish King card game
- **Card Assets**: htdebeer/SVG-cards
- **Inspiration**: Classic casino card games

---

## 📞 Contact

**Developer**: Akif AYDIN  
**Email**: [your.email@example.com](mailto:your.email@example.com)  
**GitHub**: [@yourusername](https://github.com/yourusername)

---

## 🗺️ Roadmap

### Phase 1 - Completed ✅
- [x] Core game mechanics
- [x] All 10 contracts
- [x] AI decision engine
- [x] Premium UI/UX
- [x] Unit tests

### Phase 2 - In Progress 🚧
- [ ] Audio effects
- [ ] Bidding suggestions
- [ ] Accessibility improvements

### Phase 3 - Future 🔮
- [ ] iPad/iOS support
- [ ] Multiplayer (GameKit)
- [ ] iCloud sync
- [ ] Custom themes
- [ ] Game recording

---

<div align="center">

**Made with ❤️ using SwiftUI**

[⬆ Back to Top](#-king-game)

</div>
