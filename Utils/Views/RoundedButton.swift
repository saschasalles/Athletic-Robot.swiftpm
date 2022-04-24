//
//  RoundedButton.swift
//  
//
//  Created by Sascha Sallès on 24/04/2022.
//

import SwiftUI


struct RoundedButton: View {
    var title: String
    var systemImage: String
    var backgroundColor: Color
    var action: (() -> Void)?

    var body: some View {
        Button {
            if let action = action {
                action()
            }
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.white)
                .padding()
                .background(backgroundColor)
                .cornerRadius(18)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

