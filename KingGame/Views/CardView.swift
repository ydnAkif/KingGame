import SwiftUI

struct CardView: View {
    let card: Card
    var isPlayable: Bool = true
    var isDimmed: Bool? = nil
    var isSelected: Bool = false
    var faceDown: Bool = false
    var width: CGFloat = 80

    var height: CGFloat { width * 1.4 }

    var shouldDim: Bool {
        return isDimmed ?? !isPlayable
    }

    var body: some View {
        ZStack {
            if faceDown {
                backView
            } else {
                frontView
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(isSelected && !faceDown ? 1.05 : 1.0)
        .offset(y: isSelected && !faceDown ? -12 : 0)
        .opacity(shouldDim ? 0.7 : 1.0)
        .saturation(shouldDim ? 0.6 : 1.0)
        .animation(
            .interactiveSpring(response: 0.35, dampingFraction: 0.65, blendDuration: 0),
            value: isSelected
        )
        .shadow(
            color: isSelected && !faceDown ? .black.opacity(0.4) : .black.opacity(0.3),
            radius: isSelected && !faceDown ? 10 : 4, x: 0, y: isSelected && !faceDown ? 6 : 2
        )
        .shadow(
            color: isSelected && !faceDown ? Color.goldLight.opacity(0.4) : .clear,
            radius: isSelected && !faceDown ? 15 : 0, x: 0, y: 0)
    }

    // MARK: - Ön Yüz
    var frontView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.goldLight : Color.black.opacity(0.1),
                            lineWidth: isSelected ? 2.5 : 0.5)
                )

            // SVG resmi
            Image(card.imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
        }
    }

    // MARK: - Arka Yüz
    var backView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.2, blue: 0.5),
                            Color(red: 0.05, green: 0.1, blue: 0.35),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Arka yüz deseni
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .padding(4)

            Image("back")
                .resizable()
                .scaledToFit()
                .padding(6)
                .opacity(0.9)
        }
    }
}
