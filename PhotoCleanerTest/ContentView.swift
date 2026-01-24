//
//  ContentView.swift
//  PhotoCleanerTest
//
//  Created by danilka on 22.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
                    .transition(.move(edge: .bottom))
            } else {
                HomeView()
            }
        }
        .animation(.default, value: showOnboarding)
        
    }
}

#Preview {
    ContentView()
}
