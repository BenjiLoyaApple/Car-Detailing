//
//  Color.swift
//  ChatApp
//
//  Created by Benji Loya on 16.08.2023.
//

import SwiftUI

extension Color {
    static var theme = ColorTheme()
}

struct ColorTheme {
    /// colors text & BG
    let darkWhite = Color("darkWhite")
    let darkBlack = Color("darkBlack")
    let cardBG = Color("cardBG")
    let buttonBG = Color("buttonBG")
    let createViewBG = Color("createViewBG")
    let customCardBG = Color("customCardBG")
    
    /// Change Theme
    let moon = Color("Moon")
    let sun = Color("Sun")
    let themeBG = Color("themeBG")
    
    //Task Creation
    let taskCategory = Color("taskCategory")
    
    //Task Priority
    let taskLow = Color("taskLow")
    let taskMedium = Color("taskMedium")
    let taskHigh = Color("taskHigh")
    let taskCritical = Color("taskCritical")
}

