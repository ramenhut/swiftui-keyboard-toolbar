
import SwiftUI

struct TextFieldAccessoryView: View {
    // Access to our keyboard manager in the environment. This enables
    // us to define an accessory view throughout the app, but have its
    // presentation hierarchy controlled centrally.
    @EnvironmentObject var keyboardManager : KeyboardManager
    // A binding that stores the value entered by the user into the text field.
    @Binding var value: String
    // Allows us to control whether the binding is updated. Also ensures that our
    // placeholder continues to update even if the value binding is not backed by
    // view state.
    @State var internalValue = ""
    // Used to direct focus to our accessory view.
    @FocusState private var focused : Bool
    // A placeholder that's rendered over the text field when it's empty. This is
    // rendered in two places: (1) over the original tapped text field, and (2) over
    // the accessory view text field (floating above the keyboard).
    var placeholder: String = ""
    // Foreground color (text, border)
    var foregroundColor = Color(red:100/255.0, green:100/255.0, blue:100/255.0)
    // Background color (canvas)
    var backgroundColor = Color.white
    // Accessory bar start color.
    let accessoryStartColor = Color(red:74.0/255.0, green: 78.0/255.0, blue:91.0/255.0)
    // Accessory bar end color.
    let accessoryEndColor = Color(red:59.0/255.0, green: 62.0/255.0, blue:72.0/255.0)
    // Determines the type of keyboard to display.
    var type: UIKeyboardType = .`default`
    
    var body: some View {
        HStack (alignment:.center) {
            Button {
                internalValue = value
                dismissKeyboard()
                keyboardManager.clearAccessory()
            } label: {
                Image(systemName:"xmark")
                    .resizable()
                    .frame(width:16, height:16)
                    .foregroundColor(Color.white)
                    .padding()
                    .padding(.leading, 4)
                    .offset(y:1)
            }
            
            Group {
                ZStack {
                    TextField(placeholder, text:$internalValue, onCommit: {
                        dismissKeyboard()
                        keyboardManager.clearAccessory()
                    })
                    .keyboardType(type)
                    .multilineTextAlignment(.leading)
                    .focused($focused)
                    .padding(.horizontal, 10)
                    .textPlaceholder(when:internalValue.isEmpty) {
                        if (!placeholder.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(foregroundColor.opacity(0.4))
                                .padding(.horizontal, 10)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(5.0)
            .padding(.vertical)
            
            Button {
                dismissKeyboard()
                keyboardManager.clearAccessory()
            } label: {
                Image(systemName:"keyboard.chevron.compact.down")
                    .resizable()
                    .frame(width:24, height:20)
                    .foregroundColor(Color.white)
                    .padding()
                    .padding(.trailing, 5)
                    .offset(y:1)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [accessoryStartColor.opacity(0.95), accessoryEndColor.opacity(0.95)]), startPoint: .top, endPoint: .bottom))
        .frame(width:UIScreen.main.bounds.size.width)
        .onAppear {
            focused = true
            internalValue = value
        }
        .onDisappear {
            value = internalValue
        }
    }
}

struct KMTextField: View {
    // Access to our keyboard manager in the environment.
    @EnvironmentObject var keyboardManager : KeyboardManager
    // A binding that stores the value entered by the user into the text field.
    @Binding var value: String
    // A placeholder string that renders over the field when empty.
    var placeholder: String = ""
    // Foreground color (text, border)
    var foregroundColor = Color(red:100/255.0, green:100/255.0, blue:100/255.0)
    // Background color (canvas)
    var backgroundColor = Color.white
    // Determines the type of keyboard to display.
    var type: UIKeyboardType = .`default`
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            TextField("", text: $value)
                .keyboardType(type)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(foregroundColor, lineWidth: 1)
                )
                .cornerRadius(10.0)
                .padding(.top, 10)
                .textPlaceholder(when:value.isEmpty) {
                    if (!placeholder.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(foregroundColor.opacity(0.4))
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                    } else {
                        EmptyView()
                    }
                }
                .onTapGesture {
                    keyboardManager.addAccessory {
                        AnyView(TextFieldAccessoryView(value:$value, placeholder:placeholder, type:type))
                    }
                }
        }
        .onAppear { UITextView.appearance().backgroundColor = .clear }
    }
}
