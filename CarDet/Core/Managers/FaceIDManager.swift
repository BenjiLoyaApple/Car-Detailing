//
//  FaceIDManager.swift
//  ChatDemo
//
//  Created by Benji Loya on 10.12.2024.
//

import SwiftUI
import LocalAuthentication

class FaceIDManager {
    static func authenticateIfNeeded(isFaceIDEnabled: Bool, completion: @escaping (Bool, String?) -> Void) {
        guard isFaceIDEnabled else {
            completion(true, nil)
            return
        }
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access the app.") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authenticationError?.localizedDescription ?? "Authentication failed.")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, "Biometric authentication is not available.")
            }
        }
    }
}
