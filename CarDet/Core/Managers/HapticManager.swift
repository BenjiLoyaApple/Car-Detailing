//
//  HapticManager.swift
//  Document
//
//  Created by Benji Loya on 06.02.2025.
//

import SwiftUI

class HapticManager {
    
    static let instance = HapticManager() // Singleton
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
}

/*
 HapticManager.instance.notification(type: .success)
 HapticManager.instance.impact(style: .light)
 */
