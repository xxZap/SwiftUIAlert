//
//  SwiftUITextFieldAlert.swift
//
//
//  Created by Alessio Boerio on 13/09/24.
//

import SwiftUI

/// A kind of alert that extends the base one, and also has a `TextField` inside it to let the user type something.
///
public class SwiftUITextFieldAlert: BaseAlert {
    /// The placeholder to show inside the textfield
    public var placeholder: String
    /// The action to calls whenever the user press the return key.
    public var onSubmit: ((Confirmed, String, AlertSubmitType) -> Void)

    public init(
        title: String?,
        message: String? = nil,
        alertButtons: [AlertButton],
        placeholder: String,
        onSubmit: @escaping ((Confirmed, String, AlertSubmitType) -> Void)
    ) {
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        super.init(title: title, message: message, alertButtons: alertButtons)
    }

    public static func == (lhs: SwiftUITextFieldAlert, rhs: SwiftUITextFieldAlert) -> Bool {
        lhs.id == rhs.id
    }
}
