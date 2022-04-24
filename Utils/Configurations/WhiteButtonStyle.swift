//
//  WhiteButtonStyle.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import SwiftUI

struct WhiteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.white)
            .foregroundColor(.black)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .clipShape(RoundedRectangle(cornerRadius: configuration.isPressed ? 16 : 12))
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
