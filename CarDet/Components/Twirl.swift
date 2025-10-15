//
//  Twirl.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 01.09.2025.
//

import SwiftUI

struct Twirl: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.2)
            .opacity(phase.isIdentity ? 1 : 0)
            .blur(radius: phase.isIdentity ? 0 : 4)
            .brightness(phase == .willAppear ? 1.0 : 0)
    }
}

