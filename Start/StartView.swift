//
//  StartView.swift
//  
//
//  Created by Sascha Sallès on 19/04/2022.
//

import SwiftUI

struct StartView: View {
    @State private var scale: CGFloat = 7.0
    @State private var textIsBlinking = false
    @State private var shouldPresentPresentationView = false

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Circle()
                    .fill(Material.ultraThin)
                    .shadow(color: Color(uiColor: .systemGray3), radius: 50, x: 0, y: 0)
                    .frame(height: 260)
                    .scaleEffect(scale)
                    .overlay {
                        if scale == 1 {
                            Text("🤖")
                                .font(.system(size: 85))

                        } else {
                            Image(systemName: "swift")
                                .font(.system(size: 70))
                                .symbolRenderingMode(.multicolor)
                                .foregroundColor(.orange)
                                .shadow(color: Color(uiColor: .systemGray6),
                                        radius: 30, x: 0, y: 0)
                                .opacity(scale > 1 ? 1 : 0)
                        }
                    }
                    .padding()

                VStack {
                    Text("Athletic Robot")
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .opacity(scale > 1 ? 0 : 1)
                        .padding(.top, 30)
                }


                if scale == 1 {
                    Button {
                        shouldPresentPresentationView.toggle()
                    } label: {
                        HStack(spacing: 7) {
                            Text("Press to start")
                            Image(systemName: "arrow.right")
                        }
                        .opacity(textIsBlinking ? 0.5 : 1)
                    }
                    .padding(.top, 40)
                    .buttonStyle(WhiteButtonStyle())
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            textIsBlinking.toggle()
                        }
                    }
                }
            }

            Spacer()

            // Footer
            VStack(spacing: 7) {
                Text("Swift Student Challenge")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(" WWDC 2022")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 50)

        }.background {
            LinearGradient(colors: [.teal, .indigo, .yellow],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut.delay(0.8)) {
                scale = 1.0
            }
        }
        .fullScreenCover(isPresented: $shouldPresentPresentationView) {
            RobotPresentationView(viewModel: RobotPresentationViewModel())
        }

    }
}
