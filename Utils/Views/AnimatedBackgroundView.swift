//
//  AnimatedBackground.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import Foundation
import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var start: UnitPoint = .topLeading
    @State private var end: UnitPoint = .bottomTrailing
    let colors: [Color]

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()


    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .onReceive(timer, perform: { _ in
                withAnimation(.easeInOut(duration: 7).repeatForever()) {
                    start = .bottomTrailing
                    end = .topLeading
                    start = .bottomLeading
                }
            })
    }
}
