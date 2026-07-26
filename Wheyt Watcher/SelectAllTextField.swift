import SwiftUI
import UIKit

/// Een tekstveld dat bij focus meteen de volledige inhoud selecteert.
/// Los van SwiftUI's `TextField`, die bij rechts-uitgelijnde, korte getallen
/// (zoals "18 g" in een breder vak) de cursor onbetrouwbaar plaatst — tikken op
/// de lege ruimte vóór het getal zet de cursor vóór de tekst in plaats van erna.
struct SelectAllTextField: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var textAlignment: NSTextAlignment = .right
    var textColor: UIColor = .label
    var font: UIFont = .preferredFont(forTextStyle: .body)

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.textAlignment = textAlignment
        textField.placeholder = placeholder
        textField.text = text
        textField.textColor = textColor
        textField.font = font
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textChanged(_:)),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.keyboardType = keyboardType
        uiView.textAlignment = textAlignment
        uiView.textColor = textColor
        uiView.font = font
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        @objc func textChanged(_ sender: UITextField) {
            text.wrappedValue = sender.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                textField.selectAll(nil)
            }
        }
    }

}
