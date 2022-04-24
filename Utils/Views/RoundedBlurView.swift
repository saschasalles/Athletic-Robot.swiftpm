//
//  RoundedBlurView.swift
//  
//
//  Created by Sascha Sallès on 21/04/2022.
//

import SwiftUI

struct RoundedBlurView<Content: View>: View {
    var height: CGFloat
    var width: CGFloat
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            content()
                .padding(35)
            Spacer()
        }
        .frame(width: width, height: height, alignment: .leading)
        .background(Material.ultraThin)
        .cornerRadius(35, corners: [.topLeft, .topRight])
    }
}
