//
//  Tab.swift
//  FloatTabBar
//
//  Created by Benji Loya on 20.08.2024.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case home =  "car.fill"
    case profile = "person"
    
    var title: String {
        switch self {
        case .home: "Home"
        case .profile: "Profile"
        }
    }
}
