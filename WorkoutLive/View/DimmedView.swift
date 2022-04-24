//
//  Dimmed.swift
//  
//
//  Created by Sascha Sallès on 24/04/2022.
//

import SwiftUI

struct DimmedView<Content: View>: View {
    var opacity: Double
    var content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(opacity)
            content()
        }
    }
}
