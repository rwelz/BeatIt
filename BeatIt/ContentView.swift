import SwiftUI
import Playgrounds
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var game = BeatGameModel()
    @State private var showingImporter = false
    //@FocusState private var isGameFocused: Bool // Ersetzt durch NSEvent
    
    var body: some View {
        VStack {
            Text("BEAT IT")
                .font(.largeTitle)
                .bold()

            if game.isLoading {
                ProgressView("Finding the beats…")
            } else if game.hasSong {
                Text("Score: \(game.round.score)")
                    .font(.title)
                    .monospacedDigit()
                
                Text("Get ready…")
                    .font(.title2)
                    .bold()
                    .opacity(game.isPlaying && game.currentTime < 0 ? 1 : 0)
                
                TimelineView(.animation(paused: game.isPlaying == false)) { timeline in
                    BeatLane(notes: game.round.notes, time: game.currentTime)
                    .onChange(of: timeline.date) {
                            game.update(at: timeline.date)
                    }
                }
                
                Button(game.isPlaying ? "Restart" : "Play", systemImage: "play.fill") {
                    //isGameFocused = true
                    game.play()
                }
                .buttonStyle(.borderedProminent)
                
                
                Spacer()
                
                BarLights(beats: game.currentBar, time: game.currentTime)
            }
            
            Button("Open Song", systemImage: "folder") {
                game.stop()
                showingImporter = true
            }
            .disabled(game.isLoading)

            if let message = game.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .multilineTextAlignment(.center)
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url):
                Task {
                    await game.load(url)
                }
            case .failure(let error):
                game.errorMessage = error.localizedDescription
            }
        }
        //.focusable() // alles ersetzt durch NSEvent
        //.focused($isGameFocused)
        //.focusEffectDisabled()
        //.onKeyPress(characters: .letters, phases: .down) { press in
        //    game.press(press.characters)
        //    return .handled
        //}
        .onDisappear(perform: game.stop)
        .onAppear(perform: watchKeyboard)
    }
    
    func watchKeyboard() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let isLetter = event.characters?.first?.isLetter == true
            let isShortcut = event.modifierFlags.contains(.command)
            
            guard game.isPlaying, isLetter, isShortcut == false else {
                return event
            }
            
            game.press(event.characters ?? "")
            
            // Tell the system we handled the event.
            return nil
        }
    }
}


#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
