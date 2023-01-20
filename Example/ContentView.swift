
import SwiftUI

struct ContentView: View {
    // 1. Create a KeyboardManager, which manages the state
    //    of our keyboard view system. You only need one.
    @StateObject var keyboardManager = KeyboardManager()
    // A state var to cache the user's entered text.
    @State var text = ""
    
    var body: some View {
        VStack {
            Spacer()
            // 2. Use KMTextField in place of TextField.
            KMTextField(value:$text, placeholder:"Enter some text")
        }
        .padding()
        .padding(.bottom, 30)
        .background(LinearGradient(gradient: Gradient(
            colors: [Color(red:60/255.0, green:60/255.0, blue:80/255.0),
                     Color(red:40/255.0, green:40/255.0, blue:60/255.0)]),
                                   startPoint: .top, endPoint: .bottom))
        // 3. Hook up the Keyboard Manager, which will swallow our
        //    ContentView and layer a keyboard accessory view in front
        //    of it, if one has been set. This will also add our
        //    KeyboardManager to the environment.
        .withKeyboardManager(keyboardManager:keyboardManager)
    }
}
