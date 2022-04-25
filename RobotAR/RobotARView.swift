//
//  RobotARView.swift
//  
//
//  Created by Sascha Sallès on 21/04/2022.
//

import SwiftUI

struct RobotARView: View {
    private let viewModel: RobotARSportViewModelDescriptor = RobotARSportViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State private var isMuted = false
    @State private var shouldShowMenu = false
    @State private var shouldShowWorkoutSelectionView = false
    @State private var shouldShowBottomSheet = false
    @State private var musicIsPlaying = false
    @State private var shouldShowDebugOptions = false
    @State private var currentAnimationText = ""
    @State private var currentInfoText = ""

    var body: some View {
        ZStack {
            GeometryReader { geo in
                RobotARSportView(with: viewModel)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .trailing) {
                    NavigationLink (destination: WorkoutSelectionView(),
                                    isActive: $shouldShowWorkoutSelectionView,
                                    label: { EmptyView() })

                    HeaderNavigationView(navigationLeftButtonAction: {
                        presentationMode.wrappedValue.dismiss()
                    }, navigationRightContent: {
                        Button {
                            withAnimation(.easeIn) {
                                shouldShowMenu.toggle()
                            }
                        } label: {
                            Label("Settings", systemImage: "arkit")
                        }
                        .buttonStyle(WhiteButtonStyle())
                    }, titleText: $currentInfoText)

                    if shouldShowMenu {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $isMuted) {
                                Text("Mute Music")
                                    .font(.callout)
                            }
                            .onChange(of: isMuted, perform: { _ in
                                viewModel.toggleIsMusicMuted()
                            })
                            .tint(.accentColor)

                            Divider()

                            Toggle(isOn: $shouldShowDebugOptions) {
                                Text("Debug Stats")
                                    .font(.callout)
                            }
                            .onChange(of: shouldShowDebugOptions, perform: { _ in
                                viewModel.toggleSceneStats()
                            })
                            .tint(.accentColor)

                            Divider()
                            Button {
                                viewModel.resetARSession()
                            } label: {
                                Text("Reset AR Session")
                                    .font(.callout)
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 5)
                        }
                        .padding(10)
                        .frame(width: 200)
                        .background(Material.thin)
                        .cornerRadius(18)
                        .padding(.trailing, 15)
                        .padding(.top, 3)
                        .transition(.scale)
                    }
                    Spacer()

                    if shouldShowBottomSheet {
                        RoundedBlurView(height: 280, width: geo.size.width) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("Make Tim's do some Squats or Jumping Jacks \nby tapping on actions")
                                        .lineLimit(2)
                                        .font(.system(size: 24, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)


                                    Spacer()
                                    Button {
                                        shouldShowWorkoutSelectionView.toggle()
                                    } label: {
                                        HStack(spacing: 7) {
                                            Text("Next")
                                            Image(systemName: "arrow.right")
                                        }
                                    }
                                    .buttonStyle(WhiteButtonStyle())
                                }
                                .padding(.top)

                                VStack(alignment: .leading) {
                                    Text("Tim said 🤖")
                                        .bold()
                                        .font(.title2)
                                    Text(currentAnimationText)
                                        .fontWeight(.regular)
                                        .font(.system(size: 17))
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.bottom, 30)

                                HStack(spacing: 20) {
                                    Spacer()
                                    ActivableButton(disabled: $musicIsPlaying) {
                                        Text("Lower Squat")
                                    } action: {
                                        viewModel.performRobotAnimation(ofKind: .squat(.lower))
                                    }

                                    ActivableButton(disabled: $musicIsPlaying) {
                                        Text("Upper Squat")
                                    } action: {
                                        viewModel.performRobotAnimation(ofKind: .squat(.upper))
                                    }

                                    ActivableButton(disabled: $musicIsPlaying) {
                                        Text("Jumping Jack")
                                    } action: {
                                        viewModel.performRobotAnimation(ofKind: .jumpingJack)
                                    }

                                    PlayableButton(isPlaying: $musicIsPlaying) {
                                        Label("Dance over the music ♪", systemImage: musicIsPlaying ? "pause.fill" : "play.fill")
                                    } action: {
                                        viewModel.sportOverMusic()
                                    }

                                    Spacer()
                                }
                                .padding(.bottom)

                                Spacer()
                            }
                            .padding(.vertical)
                        }.transition(.move(edge: .bottom))
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.resetARSession()
            guard let isAudioMuted = AudioService.shared.isMuted else { return }
            isMuted = isAudioMuted
        }
        .onDisappear {
            viewModel.pauseARSession()
        }
        .onReceive(viewModel.currentInfoText) { infoText in
            withAnimation(.easeIn) {
                currentInfoText = infoText
            }
        }
        .onReceive(viewModel.isRobotNodeVisible) { robotIsVisible in
            withAnimation(.easeInOut) {
                shouldShowBottomSheet = robotIsVisible
            }
        }
        .onReceive(viewModel.isMusicPlayingPublisher) { isPlaying in
            withAnimation(.easeIn) {
                musicIsPlaying = isPlaying
            }
        }
        .onReceive(viewModel.performToggleSceneStatsPublisher) { showStats in
            shouldShowDebugOptions = showStats
        }
        .onReceive(viewModel.currentAnimationSentencePublisher) { text in
            withAnimation {
                currentAnimationText = text
            }
        }
    }
}
