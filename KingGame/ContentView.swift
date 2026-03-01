import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()

    var body: some View {
        ZStack {
            // 1. Ortak Lüks Kumarhane Arkaplanı
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.1, green: 0.35, blue: 0.15), Color.black],
                center: .center,
                startRadius: 50,
                endRadius: 800
            ).ignoresSafeArea()

            // Yukarıdan vuran dinamik spot ışığı efekti
            GeometryReader { geo in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 400
                        )
                    )
                    .frame(width: max(geo.size.width * 0.8, 800), height: 400)
                    .position(x: geo.size.width / 2, y: geo.size.height / 3)
                    .blendMode(.overlay)
                    .ignoresSafeArea()
            }

            // 2. Ekran Geçişleri
            switch gameState.phase {
            case .setup:
                MainMenuView(gameState: gameState)
                    .transition(.opacity)
            default:
                // Oyun tahtası her zaman arkada durur
                GameBoardView(gameState: gameState)
                    .blur(
                        radius: (gameState.phase == .bidding || gameState.phase == .roundEnd
                            || gameState.phase == .gameEnd) ? 15 : 0
                    )
                    .disabled(gameState.phase != .playing)
                    .animation(.easeInOut(duration: 0.4), value: gameState.phase)

                // İhale (Bidding) Modalı
                if gameState.phase == .bidding {
                    Color.black.opacity(0.2).ignoresSafeArea()  // Ekstra karartma
                    BiddingView(gameState: gameState) { contract in
                        gameState.selectContract(contract)
                    }
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }

                // El Sonu (RoundEnd) Modalı
                if gameState.phase == .roundEnd {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    RoundEndView(gameState: gameState)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }

                // Oyun Sonu (GameEnd) Modalı
                if gameState.phase == .gameEnd {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    GameEndView(gameState: gameState)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
            }
        }
        .frame(minWidth: 1050, minHeight: 780)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: gameState.phase)
    }
}
