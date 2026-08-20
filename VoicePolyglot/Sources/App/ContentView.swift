import SwiftUI

/// Handles the one-time mic/speech permission request (an unavoidable system
/// dialog on first launch), then hands off to the actual game screen.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var permissionState: PermissionState = .requesting

    enum PermissionState {
        case requesting
        case granted
        case denied
    }

    var body: some View {
        Group {
            switch permissionState {
            case .requesting:
                Color.black.ignoresSafeArea()
            case .granted:
                PlayView(viewModel: viewModel)
            case .denied:
                // No microphone/speech access means the game can't work at all.
                // Shown only in this edge case; the child never sees it in normal use.
                ZStack {
                    Color.black.ignoresSafeArea()
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            viewModel.requestPermissions { granted in
                permissionState = granted ? .granted : .denied
            }
        }
    }
}
