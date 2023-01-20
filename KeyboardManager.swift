
import SwiftUI

// An epsilon needed to publish keyboard height changes
// after the current layout pass is complete (seconds).
let kKeyboardNotificationEpsilon = 0.005
// Standard duration for accessory view exit (seconds).
let kKeyboardAccessoryAnimationDuration = 0.25

class KeyboardManager : ObservableObject {
    // A keyboard accessory view that will render above the
    // keyboard when activated. May be set to arbitrary views.
    @Published var accessory : (() -> AnyView)? = nil
    // Indicates the current height of the keyboard, if active.
    @Published var isKeyboardActive: Bool = false
    // Initialize by observing future keyboard notifications.
    init() { self.observeKeyboardNotifications() }
    // A method that listens to the height of the keyboard,
    // so that we can reason about where to place overlays.
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) {
                    withAnimation (.easeInOut(duration: keyboardDuration)) {
                        self.isKeyboardActive = true
                    }
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) {
                    withAnimation (.easeInOut(duration: kKeyboardAccessoryAnimationDuration)) {
                        self.isKeyboardActive = false
                    }
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (notification) in
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) {
                    self.clearAccessory()
                }
            }
    }
    
    func addAccessory(layer : @escaping (() -> AnyView)) {
        accessory = layer
    }
    
    func clearAccessory() {
        withAnimation (.easeOut(duration: kKeyboardAccessoryAnimationDuration)) {
            self.accessory = nil
        }
    }
}

struct KeyboardAccessoryLayerView<Presenting>: View where Presenting: View {
    // The parent view that's presenting our keyboard accessory view.
    let presenting: () -> Presenting
    // Our Keyboard Accessory View Manager.
    @StateObject var keyboardManager : KeyboardManager
    
    var body: some View {
        ZStack(alignment: .center) {
            self.presenting()
                .ignoresSafeArea(.keyboard, edges: .bottom)
            if let accessory = keyboardManager.accessory {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.4))
                    .onTapGesture {
                        dismissKeyboard()
                        keyboardManager.clearAccessory()
                    }
                    .ignoresSafeArea()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                VStack {
                    Spacer()
                    accessory()
                        .opacity(keyboardManager.isKeyboardActive ? 1 : 0)
                }
            }
        }
        .environmentObject(keyboardManager)
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func textPlaceholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder overlay: () -> Content) -> some View {
            ZStack(alignment: .leading) {
                self
                overlay().opacity(shouldShow ? 1 : 0).allowsHitTesting(false)
            }
        }
    
    func withKeyboardManager(keyboardManager: KeyboardManager) -> some View {
        KeyboardAccessoryLayerView(presenting: { self }, keyboardManager:keyboardManager)
    }
}
