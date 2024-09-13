//
//  SwiftUIAlert.swift
//
//
//  Created by Alessio Boerio on 13/09/24.
//

import SwiftUI

/// A basic Alert with everything a native alert has:
/// - title
/// - message
/// - buttons
/// 
public class SwiftUIAlert: BaseAlert {
    public static func == (lhs: SwiftUIAlert, rhs: SwiftUIAlert) -> Bool {
        lhs.id == rhs.id
    }
}
