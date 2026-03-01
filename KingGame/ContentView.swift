import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()
    
    var body: some View {
        ZStack {
            switch gameState.phase {
            case .setup:
                MainMenuView(gameState: gameState)
            case .bidding:
                BiddingView(gameState: gameState) { contract in
                    gameState.selectContract(contract)
                }
            case .playing:
                GameBoardView(gameState: gameState)
            case .gameEnd:
                GameEndView(gameState: gameState)
            }
        }
        .frame(minWidth: 1000, minHeight: 750)
    }
}
