//
//  CircularProgressView.swift
//  
//
//  Created by Sascha Sallès on 24/04/2022.
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var progress: Float
    @Binding var displayText: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16.0)
                .fill(.secondary)
                .opacity(0.3)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(progress), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 16.0, lineCap: .round, lineJoin: .round))
                .fill(LinearGradient(colors: [.accentColor, .orange, .pink],
                                     startPoint: .leading, endPoint: .trailing))
                .rotationEffect(.degrees(270))
                .animation(.linear, value: progress)
                .overlay {
                    Text(displayText)
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(2)
                        .frame(width: 140, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding()
                }
        }
    }
}
