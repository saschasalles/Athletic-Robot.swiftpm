//
//  WorkoutSelectionView.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import Foundation
import SwiftUI

struct WorkoutSelectionView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var shouldShowLiveWorkoutView = false

    private let viewModel = WorkoutSelectionViewModel()
    private let gradient = LinearGradient(colors: [.orange,
                                                   .pink,
                                                   .accentColor],
                                          startPoint: .topLeading,
                                          endPoint: .bottomTrailing)

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 30) {
                NavigationLink (destination: WorkoutLiveView(),
                                isActive: $shouldShowLiveWorkoutView,
                                label: { EmptyView() })

                Text(viewModel.title)
                    .font(.system(size: 50, weight: .heavy, design: .default))
                    .foregroundColor(.clear)
                    .overlay {
                        gradient.mask {
                            Text(viewModel.title)
                                .font(.system(size: 50, weight: .heavy, design: .default))
                                .scaledToFill()
                        }
                    }

                Divider()
                    .background(Color(uiColor: .systemGray6))
                    .frame(width: 500)


                Text(viewModel.subtitle)
                    .font(.title2)
                    .foregroundColor(Color(uiColor: .darkGray))
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .lineSpacing(9)

                HStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)

                    Text(viewModel.warningText)
                        .fontWeight(.regular)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
                .background(gradient)
                .cornerRadius(22)
                .padding(.horizontal, 20)
                .padding(.top, 20)

                WorkoutView(title: viewModel.workout.title,
                            buttonGradient: gradient,
                            level: viewModel.workout.level,
                            levelColor: viewModel.workout.levelColor,
                            instructions: viewModel.workout.instructions,
                            imageTitle: viewModel.workout.presentationImageTitle) {
                    shouldShowLiveWorkoutView.toggle()
                }
                .padding(.horizontal, 30)
                .shadow(color: Color(uiColor: .systemGray5), radius: 30, x: 2, y: 3)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .overlay(alignment: .topLeading) {
            HStack(alignment: .top) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                .padding(12)
                .background(Color.accentColor)
                .clipShape(Circle())
                .mask {
                    LinearGradient(colors: [.clear,
                                            .accentColor.opacity(0.3),
                                            .accentColor.opacity(0.7),
                                            .accentColor],
                                   startPoint: .topLeading,
                                   endPoint: .center)
                }

                Spacer()
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 50)
        }
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

struct WorkoutSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSelectionView()
            .previewInterfaceOrientation(.portraitUpsideDown)

    }
}
