//
//  Judgement.swift
//  BeatIt
//
//  Created by Robert Welz on 12.10.26.
//

import Foundation
import SwiftUI

enum Judgement {
    case good, bad
    
    var points: Int {
        switch self {
            case .good: 1
            case .bad: -1
        }
    }
    
    var color: Color {
        switch self {
            case .good: .green
            case .bad: .red
        }
    }
}
