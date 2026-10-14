//
//  BeatRound.swift
//  BeatIt
//
//  Created by Robert Welz on 12.10.26.
//

import Foundation

struct BeatRound {
    static let hitWindow = 0.1
    var notes = [BeatNote]()
    var score = 0
    
    mutating func press(_ letter: String, at time: Double) {
            // No best choice yet.
        var closestIndex: Int?
        var closestDistance = Double.infinity
        
        for index in 0..<notes.count {
            let distance = abs(notes[index].time - time)
            
                // Our best choice so far.
            if distance < closestDistance {
                closestIndex = index
                closestDistance = distance
            }
        }
        
            // If we have no best choice, exit.
        guard let closestIndex else { return }
        guard notes[closestIndex].judgement == nil else { return }
        
        let isCorrectLetter = letter == notes[closestIndex].letter
        let isTouchingLine = closestDistance <= Self.hitWindow
        
        let judgement: Judgement = if isCorrectLetter && isTouchingLine {
            .good
        } else {
            .bad
        }
        
        notes[closestIndex].judgement = judgement
        score += judgement.points
    }
    
    mutating func markMissedNotes(at time: Double) {
        for index in 0..<notes.count {
            let isTooLate = time - notes[index].time > Self.hitWindow
            
            if notes[index].judgement == nil && isTooLate {
                notes[index].judgement = .bad
                score += Judgement.bad.points
            }
        }
    }
}
