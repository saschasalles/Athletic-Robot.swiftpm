//
//  View+CornerRadius.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedRectangleShape(radius: radius, corners: corners))
    }
}
