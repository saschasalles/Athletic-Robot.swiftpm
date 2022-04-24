//
//  TogglableButton.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import Foundation
import SwiftUI


struct ActivableButton<Content: View>: View {
    @Binding var disabled: Bool
    
    var content: () -> Content
    var action: () -> Void


    var gradient = LinearGradient(colors: [.orange, .accentColor],
                                          startPoint: .topLeading,
                                          endPoint: .bottomTrailing)

    var body: some View {
        Button {
            action()
        } label: {
            content()
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .padding()
        .foregroundColor(.white)
        .blur(radius: disabled ? 2 : 0)
        .scaleEffect(disabled ? 0.9 : 1)
        .background(gradient)
        .saturation(disabled ? 0.3 : 1)
        .transition(.opacity)
        .cornerRadius(18)
        .disabled(disabled)
        .animation(.easeInOut, value: disabled)
        .buttonStyle(ScaleButtonStyle())
    }
}
