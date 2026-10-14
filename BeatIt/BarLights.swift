//
//  BarLights.swift
//  BeatIt
//
//  Created by Robert Welz on 09.10.26.
//

import SwiftUI

struct BarLights: View {
    var beats: [Double]
    var time: Double
    
    var body: some View {
        let currentBeat = beats.last { $0 <= time }
        
        HStack(spacing: 20) {
            ForEach(beats, id: \.self) { beat in
                Circle()
                    .fill(beat == currentBeat ? Color.cyan : Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
            }
        }
        .frame(height: 80)
        .padding()
    }
}

#Preview {
    BarLights(beats: [], time: 0)
}
