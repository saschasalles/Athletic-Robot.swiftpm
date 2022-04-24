//
//  PlayableButton.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import SwiftUI

struct PlayableButton<Content: View>: View {
    @Binding var isPlaying: Bool
    var gradient = LinearGradient(colors: [.orange, .accentColor],
                                          startPoint: .topLeading,
                                          endPoint: .bottomTrailing)

    var content: () -> Content
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content()
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .padding()
        .foregroundColor(.white)
        .background {
            isPlaying ? AnyView(AnimatedBackgroundView(colors: [.orange, .accentColor])) : AnyView(gradient)
        }
        .transition(.opacity)
        .cornerRadius(18)
        .animation(.easeInOut, value: isPlaying)
        .buttonStyle(ScaleButtonStyle())
    }
}

