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
                        radius: (gameState.phase == .bidding && !gameState.biddingPlayer.isAI
                            || gameState.phase == .roundEnd || gameState.phase == .gameEnd) ? 15 : 0
                    )
                    .disabled(gameState.phase != .playing)
                    .animation(.easeInOut(duration: 0.4), value: gameState.phase)

                // İhale (Bidding) Modalı - Sadece insan oyuncu için
                if gameState.phase == .bidding {
                    if !gameState.biddingPlayer.isAI {
                        Color.black.opacity(0.2).ignoresSafeArea()  // Ekstra karartma
                        BiddingView(gameState: gameState) { contract in
                            gameState.selectContract(contract)
                        }
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                    } else {
                        // AI seçerken gösterilecek şık küçük pop-up
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .goldLight))
                                .scaleEffect(1.5)

                            Text("\(gameState.biddingPlayer.name) kontrat seçiyor...")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(
                                Color.goldMid.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: gameState.phase)
                    }
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
