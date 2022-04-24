//
//  Int+Ordinal.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//

import Foundation



extension Int {
    var ordinal: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: Int64(self)))
    }
}
