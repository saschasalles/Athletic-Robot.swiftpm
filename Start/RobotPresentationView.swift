//
//  RobotPresentationView.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import SwiftUI
import Combine

struct RobotPresentationView: View {
    private var viewModel: RobotPresentationViewModelDescriptor

    init(viewModel: RobotPresentationViewModelDescriptor) {
        self.viewModel = viewModel
    }

    @State private var currentText = ""
    @State private var isRobotRotating = true
    @State private var hasFinishTextFlow = false
    @State private var shouldShowARView = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    NavigationLink (destination: RobotARView(),
                                    isActive: $shouldShowARView,
                                    label: { EmptyView() })

                    ZStack(alignment: .bottom) {
                        VStack {
                            ScenePreviewView(with: viewModel.scenePreviewViewModel)
                                .frame(width: geo.size.width)
                            Spacer()
                        }


                        RoundedBlurView(height: geo.size.height * 1/3,
                                        width: geo.size.width) {
                            Text(currentText)
                                .bold()
                                .foregroundColor(.white)
                                .font(.system(.title, design: .default))
                                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                                .lineLimit(7)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(5)
                        }
                                        .overlay(alignment: .bottomTrailing) {
                                            if hasFinishTextFlow {
                                                HStack {
                                                    Spacer()
                                                    Button {
                                                        shouldShowARView.toggle()
                                                        if isRobotRotating {
                                                            viewModel.scenePreviewViewModel.toggleRobotRotation()
                                                        }
                                                    } label: {
                                                        HStack {
                                                            Text("Next")
                                                            Image(systemName: "arkit")
                                                        }
                                                    }
                                                    .buttonStyle(WhiteButtonStyle())

                                                }
                                                .padding(.horizontal, 35)
                                                .padding(.bottom, 40)
                                                .transition(.opacity)
                                            }
                                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                .overlay(alignment: .topTrailing) {
                    HStack(alignment: .top) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding(12)
                                .background(Material.ultraThin)
                                .clipShape(Circle())
                        }

                        Spacer()
                        Button {
                            viewModel.scenePreviewViewModel.toggleRobotRotation()
                        } label: {
                            Text(isRobotRotating ? "Stop Rotation" : "Play Rotation")
                        }
                        .buttonStyle(WhiteButtonStyle())
                    }
                    .padding(35)
                }
                .background(Color.indigo)
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .onReceive(viewModel.currentText) { text in
            withAnimation(.easeIn) {
                currentText = text
            }
        }
        .onReceive(viewModel.scenePreviewViewModel.isRobotRotating) { isRotating in
            isRobotRotating = isRotating
        }
        .onReceive(viewModel.hasFinishedTextFlow) { flow in
            withAnimation(.easeIn)  {
                hasFinishTextFlow = flow
            }
        }
    }
}
