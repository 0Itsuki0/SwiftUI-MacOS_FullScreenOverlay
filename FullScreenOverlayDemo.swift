import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ScreenOverlayControlView()
        }

        // UtilityWindow or WindowGroup will not work
        Window("", id: FullScreenOverlay.id, content: {
            FullScreenOverlay()
        })
        

    }
}


struct FullScreenOverlay: View {
    static let id = "FullScreenOverlay"
    
    @Environment(\.dismiss) private var dismiss
    @State private var isInitial = true

    var body: some View {
        VStack {
            Image(systemName: "star.circle")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.black)
                .padding()
        }
        .frame(width: NSScreen.main?.frame.size.width, height: NSScreen.main?.frame.size.height)
        .contentShape(Rectangle())
        .background(.gray.opacity(0.5))
        .onTapGesture {
            dismiss()
        }
        .onAppear {
            // if isInitial is true, we are opening the window only so that the next time we actually need to use it, we can configure it before opening
            if self.isInitial {
                self.isInitial = false
                dismiss()
                return
            }
        }
    }
}

struct ScreenOverlayControlView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(action: {
            
            // configure the window in `onAppear` after calling openWindow will not work (completely)
            // some of the properties set will not be reflected.
            guard let window = NSApplication.shared.windows.first(where: {$0.identifier?.rawValue == FullScreenOverlay.id}) else {
                return
            }
            
            print("window found")
            window.level = .screenSaver // popUpMenu will also work
            
            // set the position of the window
            window.setFrameOrigin(NSPoint(x: 0, y: 0))

            // remove title and buttons
            window.styleMask.remove(.titled)
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            // so that the window can follow the virtual desktop
            window.collectionBehavior.insert(.canJoinAllSpaces)
            
            // set it clear here so the configuration in UtilityWindowView will be reflected as it is
            window.backgroundColor = .clear

            openWindow(id: FullScreenOverlay.id)

        }, label: {
            Text("Open")
        })
        .onAppear {
            // to make sure the UtilityWindowView is created
            // so that the next time we actually need to use it, we can configure it before opening
            //
            // if we don't call openWindow(id: UtilityWindowView.id) for at least once,
            // NSApplication.shared.windows will not contains the window instance.
            //
            // That is before the following call,  NSApplication.shared.windows.map(\.identifier?.rawValue) will not contain UtilityWindowView.id
            //
            // Also, configure the window within the Button closure right after calling openWindow(id: FullScreenOverlay.id) or within FullScreenOverlay.onAppear will not work completely either
            // Some of the properties will not be reflected.
            guard NSApplication.shared.windows.first(where: {$0.identifier?.rawValue == FullScreenOverlay.id}) == nil else {
                // already created and configured
                return
            }
            openWindow(id: FullScreenOverlay.id)
        }
    }
}
