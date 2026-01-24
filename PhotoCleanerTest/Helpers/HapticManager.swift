//
//  HapticManager.swift
//  Formee
//
//  Created by danilka on 25.06.2025.
//

import Foundation
import SwiftUI

extension View {
    func hapticFeedback<Value: Equatable>(option: HapticsType = .selection, onChangeOf value: Value?) -> some View {
        modifier(HapticViewModifier(option: option, value: value))
    }
}

struct HapticViewModifier<Value : Equatable>: ViewModifier {
    
    let option: HapticsType
    let value: Value?
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .onChange(of: value) { _ in
                HapticManager.instance.generateFeedback(option)
            }
    }
    
}

enum HapticsType: Int, CaseIterable {
    case error = 0, success = 1, warning = 2
    case light = 10, medium = 11, soft = 12, heavy = 13, rigid = 14
    case selection
}

class HapticManager {
    
    static let instance = HapticManager() //Singleton
    
    private func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        
        generator.notificationOccurred(type)
    }
    
    private func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        
        generator.impactOccurred()
    }
    
    private func selection() {
        let generator = UISelectionFeedbackGenerator()
        
        generator.selectionChanged()
    }
    
    func generateFeedback(_ style: HapticsType) {
        
        switch style {
        case .error, .success, .warning:
            notification(type: UINotificationFeedbackGenerator.FeedbackType(rawValue: style.rawValue) ?? .success)
        case .light, .medium, .soft, .heavy, .rigid:
            impact(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: style.rawValue - 10) ?? .light)
        case .selection:
            selection()
        }
    }
    
}
