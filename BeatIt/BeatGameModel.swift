    //
    //  BeatGame.swift
    //  BeatIt
    //
    //  Created by Robert Welz on 05.10.26.
    //
import AVFoundation
import SwiftUI
import MusicUnderstanding

@Observable
class BeatGameModel {
    var errorMessage: String?
    
    var isLoading = false
    var hasSong = false
    var beats = [Double]()
    var bars = [Double]()
    
    var isPlaying = false
    var player: AVAudioPlayer?
    
    var currentTime = 0.0
    var startTime = Date.now
    
    var round = BeatRound()
    
    var currentBar: [Double] {
        guard isPlaying else { return [] }
        guard let barStart = bars.last(where: { $0 <= currentTime }) else {
            return []
        }
        
        let barEnd = bars.first { $0 > currentTime } ?? .infinity
        return beats.filter { $0 >= barStart && $0 < barEnd }
    }
    
    func load(_ url: URL) async {
        
        stop()
        
        errorMessage = nil
        
        round = BeatRound()
        
        isLoading = true
        defer { isLoading = false }
        
        let accessed = url.startAccessingSecurityScopedResource()
        
        defer{
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let asset = AVURLAsset(url: url)
            
            let session = try await MusicUnderstandingSession(asset: asset)
            let result = try await session.analyze(for: [.rhythm])
            
            beats = result.rhythm?.beats.map(\.seconds) ?? []
            bars = result.rhythm?.bars.map(\.seconds) ?? []
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            
            hasSong = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func play() {
        guard let player else { return }
        
        stop()
        errorMessage = nil
        player.currentTime = 0
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let notes = beats.map { beat in
            BeatNote(time: beat, letter: String(alphabet.randomElement()!))
        }
        
        round = BeatRound(notes: notes)
        
        currentTime = -2
        startTime = .now.addingTimeInterval(2)
        player.play(atTime: player.deviceCurrentTime + 2)
        
        player.play()
        isPlaying = true
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
    }
    
    func update(at date: Date) {
        guard isPlaying, let player else { return }
        
        currentTime = date.timeIntervalSince(startTime)
        
        if currentTime > player.duration + BeatRound.hitWindow {
            stop()
        }
    }
    
    func press(_ letter: String) {
        guard isPlaying else { return }
        
        let pressTime = Date.now.timeIntervalSince(startTime)
        round.press(letter.uppercased(), at: pressTime)
    }
}
