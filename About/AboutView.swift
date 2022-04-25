//
//  AboutView.swift
//  
//
//  Created by Sascha Sallès on 24/04/2022.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) private var presentationMode
    private let viewModel = AboutViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Spacer()
                    Text("About Athletic Robot")
                        .font(.system(size: 40,
                                      weight: .bold,
                                      design: .serif))
                        .fontWeight(.heavy)
                    Spacer()
                }

                VStack(alignment: .leading) {
                    VStack(spacing: 25) {
                        Image("me")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 600, height: 400, alignment: .center)
                            .cornerRadius(20)

                        Text(viewModel.funnySentence)
                            .font(.system(.body, design: .default))
                            .foregroundColor(.secondary)
                            .italic()

                        Divider()
                            .frame(width: 400)
                        Text("About me")
                            .font(.system(.title2, design: .serif))
                            .bold()

                        Text(viewModel.presentationText)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(5)
                        Divider()
                            .frame(width: 400)

                        Text("About the concept")
                            .font(.system(.title2, design: .serif))
                            .bold()

                        Text(viewModel.athleticRobotText)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(5)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                VStack(alignment: .center, spacing: 30) {
                    Divider()
                        .frame(width: 400)
                    Text("About the ressources")
                        .font(.system(.title2, design: .serif))
                        .bold()

                    List {
                        Text("I designed entirely Tim Coach with Maya, and Xcode SceneKit Editor")
                        Text("I composed entirely Tim's favorite music on Garage Band")
                        Text("All the animations were realized programmatically way by myself.")
                        Text("I created the Workout Classifier with CreateML")
                        Text("The classifier was trained with mixed data, one part from the UCF101 public dataset, one part with personal data (Jumping Jacks and Other Label)")
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 400)
                }

                Spacer()

            }
            .padding()
        }.overlay(alignment: .topLeading) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Material.regular, .secondary)
                        .font(.system(size: 40))

                }
                .buttonStyle(ScaleButtonStyle())
                Spacer()
            }
            .padding()
        }
    }
}


struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
