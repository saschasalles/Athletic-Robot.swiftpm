//
//  WorkoutView.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import SwiftUI

struct WorkoutView: View {
    var title: String
    var buttonGradient: LinearGradient
    var level: String
    var levelColor: Color
    var instructions: [String]
    var imageTitle: String
    var mainAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack {
                Image(imageTitle)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 220)

            .mask {
                LinearGradient(colors: [.clear,
                                        Color(uiColor: .systemBackground).opacity(0.7),
                                        Color(uiColor: .systemBackground).opacity(0.7),
                                        Color(uiColor: .systemBackground).opacity(0.7)],
                               startPoint: .bottom,
                               endPoint: .top)
            }

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                        Text("Challenge")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .padding(.bottom)
                    }
                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Difficulty")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color(uiColor: .systemGray))
                        Text(level)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(levelColor)
                    }
                }
                .padding(.bottom)

                Text("Rules")
                    .bold()
                    .font(.title3)
                List {
                    ForEach(Array(zip(instructions.indices, instructions)), id: \.0) { index, rule in
                        HStack {
                            let newIndex: Int = index + 1
                            Text("\(newIndex.ordinal ?? String(newIndex)) Step")
                            Spacer()
                            Text(rule)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: 140)
                Spacer()

                HStack {
                    Spacer()
                    Button(action: mainAction) {
                        HStack(spacing: 10) {
                            Text("Try")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                            Image(systemName: "chevron.right.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .padding()
                        .frame(width: 200)
                        .background(buttonGradient)
                        .cornerRadius(20)
                    }
                }
                .padding(.top, 30)

            }
        }
        .padding(.trailing, 20)
        .padding(.vertical, 20)

        .background(.background)
        .cornerRadius(25)
    }
}


