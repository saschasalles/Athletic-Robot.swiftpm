//
//  Song.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//

import Foundation

enum SongKind: String {
    case tonic = "Tonic Song"
    case soft = "Soft Song"
}

struct Song {
    var displayedName: String { kind.rawValue }
    let kind: SongKind
    let url: URL?
    let triggerPoints: [TimeInterval : AnimationKind]

    static let softSong = Song(kind: .soft,
                               url: Bundle.main.url(forResource: "WWDC22SoftSong",
                                                    withExtension: "m4a"),
                               triggerPoints: [
                                    9.9 : .squat(.upper),
                                    12.2 : .jumpingJack,
                                    14.8  : .squat(.lower),
                                    17.7 : .jumpingJack,
                                    19.8  : .squat(.lower),
                                    21.0 : .squat(.lower),
                                    22.8 : .squat(.lower),
                                    23.8 : .squat(.lower ),
                                    25.0  : .jumpingJack,
                                    27.9  : .jumpingJack,
                                    30.0 : .squat(.upper),
                                    31.9  : .squat(.upper),
                                    32.9 : .jumpingJack,
                                    34.0  : .jumpingJack,
                                    35.8 : .squat(.lower),
                                    36.9  : .squat(.lower),
                                    37.9  : .jumpingJack,
                                    38.7 : .jumpingJack,
                                    39.4  : .jumpingJack
                               ])
}
