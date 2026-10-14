//
//  BeatLane.swift
//  BeatIt
//
//  Created by Robert Welz on 12.10.26.
//

import SwiftUI

struct BeatLane: View {
    var noteSize = 88.0
    var notes: [BeatNote]
    var time: Double
    
    var body: some View {
        Canvas { context, size in
            let targetX = min(noteSize * 1.5, size.width * 0.25)
            let centerY = size.height / 2
            let speed = noteSize / 2 / BeatRound.hitWindow
            
            let targetLine = CGRect(
                x: targetX - 2,
                y: 0,
                width: 4,
                height: size.height
            )
            
            context.fill(Path(targetLine), with: .color(.cyan))
            
            for note in notes {
                let x = targetX + (note.time - time) * speed
                
                    // make sure this is on screen
                if x < -noteSize || x > size.width + noteSize {
                    continue
                }
                
                let rect = CGRect(
                    x: x - noteSize / 2,
                    y: centerY - noteSize / 2,
                    width: noteSize,
                    height: noteSize
                )
                
                let color = note.judgement?.color ?? .gray.opacity(0.5)
                
                context.fill(
                    Path(roundedRect: rect, cornerRadius: noteSize / 4),
                    with: .color(color)
                )
                
                let letter = Text(note.letter)
                    .font(.system(size: 36))
                    .bold()
                
                context.draw(letter, at: CGPoint(x: x, y: centerY))
            }
        }
        .frame(height: noteSize * 2)
        .background(.gray.opacity(0.1))
    }
}

#Preview {
    BeatLane(notes: [], time: 0)
}
