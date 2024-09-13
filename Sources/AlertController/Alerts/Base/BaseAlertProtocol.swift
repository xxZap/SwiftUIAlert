//
//  BaseAlertProtocol.swift
//
//
//  Created by Alessio Boerio on 13/09/24.
//

import SwiftUI

protocol BaseAlertTypeProtocol {
    var title: String? { get }
    var message: String? { get }
}

protocol BaseAlertProtocol: BaseAlertTypeProtocol & Identifiable & Equatable {
    var alertButtons: [AlertButton] { get }
}

public typealias Confirmed = Bool

/// A custom structure to define the desired button and its action, that will be automatically translated into
/// a system button behind the scenes.
///
public struct AlertButton: Identifiable {
    /// An identifier for the current button alert instance.
    public let id = UUID()
    /// The content text of the button.
    public let label: String
    /// The button role.
    /// It will be automatically translated into system's button role.
    public let role: AlertButtonRole
    /// The action to perform once the button is being tapped.
    public let action: () -> Void

    public init(
        _ label: String,
        role: AlertButtonRole = .default,
        action: @escaping () -> Void = { }
    ) {
        self.label = label
        self.role = role
        self.action = action
    }

    func toSwiftUIButton(onSubmit: ((Confirmed) -> Void)? = nil) -> some View {
        switch self.role {
        case .`default`:
            return Button {
                action()
                onSubmit?(true)
            } label: {
                Text(self.label)
            }
        case .cancel:
            return Button(role: .cancel) {
                action()
                onSubmit?(false)
            } label: {
                Text(self.label)
            }
        case .destructive:
            return Button(role: .destructive) {
                action()
                onSubmit?(false)
            } label: {
                Text(self.label)
            }
        }
    }
}

/// The way the user is interacting with the alert.
public enum AlertSubmitType {
    case keyboard
    case button
}

/// Bridge to translate `BaseAlert`'s custom buttons to system ones.
public enum AlertButtonRole: Equatable {
    case `default`
    case destructive
    case cancel

    var toSystemRole: ButtonRole? {
        switch self {
        case .`default`:
            return .none
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

/// Bridge to translate `BaseAlert`'s custom role to system ones.
extension UIAlertAction.Style {
    var role: ButtonRole? {
        switch self {
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        case .default:
            return nil
        @unknown default:
            return nil
        }
    }
}
