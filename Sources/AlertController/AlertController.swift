//
//  AlertController.swift
//
//
//  Created by Alessio Boerio on 13/09/24.
//

import SwiftUI
import Foundation

/// The main actor who shows or hide the alerts.
public class AlertController: ObservableObject {
    @Published var alert: BaseAlert?
}

// MARK: - Key

/// The key to access to the current's environment AlertController:
public struct AlertControllerKey: EnvironmentKey {
    public static let defaultValue = AlertController()
}

extension EnvironmentValues {
    var alertController: AlertController {
        get { self[AlertControllerKey.self] }
        set { self[AlertControllerKey.self] = newValue }
    }
}

// MARK: - View Extensions

public extension View {
    /// This function creates a new instance of the `AlertController` and saves it to this context's Environment,
    /// so you'll be able to access to it through the native @Environment key:
    ///
    /// - Example:
    ///
    /// struct MyView: View {
    ///     @StateObject private var alertController = AlertController()
    ///     var body: some View {
    ///         Group {
    ///             MySubview
    ///         }
    ///         .registerAlertController(alertController)
    ///     }
    /// }
    ///
    /// struct MySubview: View {
    ///     @Environment(\.alertController) private var alertController
    ///     ...
    ///     }
    /// }
    ///
    /// - Parameter alertController: the `AlertController` instance to be use from the @Environment
    ///
    /// - Returns: returns the configured view, ready to be used from itself and from its subviews.
    ///
    func registerAlertController(_ alertController: AlertController) -> some View {
        ZStack {
            // The reson for this is because SwiftUI, whenever an alert is presented or dismissed,
            // force the body of the attached view to be refreshed and this causes an undesired blink.
            // One way to fix this (there are many) is to have a ZStack and the alert to be presented/dismissed from
            // another transparent view at the same level of our rootview.
            Color.clear
                .alert(
                    isPresented: Binding(
                        // Return the alertController's alert
                        get: { alertController.alert != nil },
                        // Clear the alertController's alert if the alert is being dismissed
                        set: { if !$0 { DispatchQueue.main.async { alertController.alert = nil } } }
                    ),
                    alert: alertController.alert
                )

            self
        }
        // AlertController's instance registration to the current environment
        .environment(\.alertController, alertController)
    }

    private func alert(isPresented: Binding<Bool>, alert: BaseAlert?) -> some View {
        let alert = alert ?? SwiftUIAlert(title: nil, alertButtons: [])

        return Group {
            if let alert = alert as? SwiftUIAlert {
                self.alert(
                    alert.title ?? "",
                    isPresented: isPresented,
                    actions: {
                        ForEach(alert.alertButtons) { button in
                            button.toSwiftUIButton()
                        }
                    },
                    message: {
                        if let message = alert.message {
                            Text(message)
                        }
                    }
                )
            } else if let textFieldAlert = alert as? SwiftUITextFieldAlert {
                var text: String = ""
                self.alert(
                    textFieldAlert.title ?? "",
                    isPresented: isPresented,
                    actions: {
                        TextField(
                            textFieldAlert.placeholder,
                            text: Binding(
                                get: { text },
                                set: { text = $0 }
                            )
                        )
                        .autocorrectionDisabled()
                        .onSubmit {
                            textFieldAlert.onSubmit(true, text, .keyboard)
                        }

                        ForEach(textFieldAlert.alertButtons) { button in
                            button.toSwiftUIButton { confirmed in
                                textFieldAlert.onSubmit(confirmed, text, .button)
                            }
                        }
                    },
                    message: {
                        if let message = textFieldAlert.message {
                            Text(message)
                        }
                    }
                )
            }
        }
    }
}
