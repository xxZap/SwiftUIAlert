//
//  BaseAlert.swift
//
//
//  Created by Alessio Boerio on 13/09/24.
//

import SwiftUI

/// The base class for the alerts used by the `AlertController`.
public class BaseAlert: BaseAlertProtocol {
    /// An identifier for the current alert instance.
    public var id = UUID()
    /// The alert's title.
    public var title: String?
    /// The alert's body message.
    public var message: String?
    /// The list of buttons attached to the alert.
    public var alertButtons: [AlertButton]

    public init(
        title: String?,
        message: String? = nil,
        alertButtons: [AlertButton]
    ) {
        self.title = title
        self.message = message
        self.alertButtons = alertButtons
    }

    public static func == (lhs: BaseAlert, rhs: BaseAlert) -> Bool {
        lhs.id == rhs.id
    }
}
