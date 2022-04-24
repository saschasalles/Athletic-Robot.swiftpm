//
//  RoundedRectangleShape.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import SwiftUI

struct RoundedRectangleShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
