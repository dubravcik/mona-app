import SwiftUI

/// The entire app, screen-wise: one enormous picture, tap it, listen, done.
/// No text, no menus, no score — by design.
struct PlayView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()

                Button(action: viewModel.tapPicture) {
                    pictureContent
                        .frame(
                            width: min(geometry.size.width, geometry.size.height) * 0.8,
                            height: min(geometry.size.width, geometry.size.height) * 0.8
                        )
                        .scaleEffect(viewModel.state == .listening ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.state == .listening)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.state != .idle)
            }
        }
        .statusBar(hidden: true)
    }

    @ViewBuilder
    private var pictureContent: some View {
        if let uiImage = UIImage(named: viewModel.currentWord.id) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 40))
        } else {
            Text(viewModel.currentWord.emoji)
                .font(.system(size: 260))
                .minimumScaleFactor(0.3)
        }
    }

    /// A gentle, unlabeled color shift per language — purely a subtle cue, never
    /// meant to be "read" as a menu or a score.
    private var backgroundColor: Color {
        switch viewModel.currentLanguage {
        case .english: return Color(red: 0.87, green: 0.94, blue: 1.0)
        case .spanish: return Color(red: 1.0, green: 0.93, blue: 0.85)
        case .mandarin: return Color(red: 1.0, green: 0.87, blue: 0.87)
        case .japanese: return Color(red: 0.9, green: 1.0, blue: 0.9)
        }
    }
}
