//
//  HeaderNavigationView.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//

import SwiftUI


struct HeaderNavigationView<T: View>: View  {
    var navigationLeftButtonAction: () -> Void
    var navigationRightContent: () -> T
    @Binding var titleText: String

    var body: some View {
        HStack(spacing: 30) {
            Button {
                navigationLeftButtonAction()
            } label: {
                Image(systemName: "arrow.left")
                    .imageScale(.large)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
            }

            Text(titleText)
                .font(.system(size: 25, weight: .medium, design: .default))
                .transition(.opacity)

            Spacer()

            navigationRightContent()

        }
        .padding()
        .background(Material.thin)
        .cornerRadius(25)
        .padding(.top, 25)
        .padding(.horizontal)
    }
}

