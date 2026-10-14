# 🎵 Beat It! (Beschreibung von ClaudeAI)

Ein Rhythmusspiel für macOS, mit dem man **Zehnfingerschreiben** übt. Im Takt eines selbst gewählten Songs gleiten Buchstaben über den Bildschirm. Man muss jeden Buchstaben genau dann tippen, wenn er die cyanfarbene Linie kreuzt.

Die Beats werden mit Apples **Music Understanding Framework** direkt aus der Audiodatei ermittelt. Das Spiel folgt also dem echten Rhythmus des Songs, auch wenn sich das Tempo ändert.

> Basierend auf dem Live-Stream [„Beat It!“](https://www.hackingwithswift.com/plus/live-streams/beat-it) von Paul Hudson auf Hacking with Swift+.

---

## Spielprinzip

- Einen beliebigen lokalen Song öffnen (zum Einstieg lieber etwas Langsames).
- Auf **Play** klicken. Nach einem **2-Sekunden-Countdown** („Get ready…“) startet die Musik.
- Buchstaben fahren von rechts nach links und erreichen die Ziellinie **genau auf dem Beat**.
- **Richtiger Buchstabe zur richtigen Zeit** → +1 Punkt, Kachel wird **grün**.
- **Falscher Buchstabe, falsches Timing oder verpasst** → −1 Punkt, Kachel wird **rot**.
- Unten zeigt eine Reihe Lichter die Beats des aktuellen Takts an.

Groß- und Kleinschreibung spielt keine Rolle, Shift muss man also nicht gedrückt halten.

## Voraussetzungen

- **Xcode 27** oder neuer
- **macOS 27** oder neuer
- Eine lokale Audiodatei

Das Projekt ist für macOS gebaut. iOS-Support lässt sich nachrüsten, dann muss man aber die Tastatureingabe über `NSEvent` ersetzen (siehe unten).

## Installation

1. [Komplettes Projekt herunterladen](https://www.hackingwithswift.com/files/plus/live-streams-beatit.zip) (HWS+) oder das Repository klonen.
2. `BeatIt.xcodeproj` in Xcode öffnen.
3. Mit **⌘R** starten.

## Projektstruktur

| Datei | Aufgabe |
|---|---|
| `ContentView.swift` | Haupt-UI: Song öffnen, Score, Countdown, `TimelineView`, Play/Restart, Tastatur-Monitor |
| `BeatGameModel.swift` | `@Observable`-Modell: Song laden und analysieren, Wiedergabe, Spielzeit, Eingaben weiterleiten |
| `BeatRound.swift` | Eine Spielrunde: Noten, Score, Treffer-Bewertung, verpasste Noten |
| `BeatNote.swift` | Eine Note: Zeitpunkt, Buchstabe, Bewertung |
| `Judgement.swift` | Enum `good` / `bad` mit Punkten und Farbe |
| `BeatLane.swift` | `Canvas` mit Ziellinie und bewegten Buchstaben-Kacheln |
| `BarLights.swift` | Kreise, die die Beats des aktuellen Takts anzeigen |

## Wie es funktioniert

### 1. Rhythmus finden

Nach der Auswahl über `.fileImporter` analysiert eine `MusicUnderstandingSession` den Song, und zwar nur auf `.rhythm`. Verwendet werden:

- **Beat-Zeitstempel**: wann genau jeder Beat fällt
- **Takt-Zeitstempel**: wie die Beats zu Takten gruppiert sind (nicht immer 4/4)

Die Werte kommen als `CMTime` zurück und werden in Sekunden (`Double`) umgerechnet. Weil die Datei außerhalb der Sandbox liegen kann, wird der Zugriff mit `startAccessingSecurityScopedResource()` angefordert und per `defer` wieder freigegeben.

### 2. Abspielen und Zeit messen

- `AVAudioPlayer` startet die Musik mit `play(atTime: deviceCurrentTime + 2)`, also 2 Sekunden in der Zukunft.
- Das Modell merkt sich `startTime` und berechnet die Spielzeit über `Date`. Sie läuft von **−2 bis 0** und dann durch den Song.
- Ein `TimelineView(.animation)` aktualisiert die Zeit bis zu 120-mal pro Sekunde.

### 3. Buchstaben zeichnen

Beim Start einer Runde bekommt jeder Beat **einmalig** einen zufälligen Buchstaben. Die `BeatLane` zeichnet alles in einem `Canvas`:

```swift
let speed = noteSize / 2 / BeatRound.hitWindow          // 88 / 2 / 0.1 = 440 pt/s
let x = targetX + (note.time - time) * speed            // Position relativ zur Ziellinie
```

Die Geschwindigkeit ist so gewählt, dass eine Kachel **genau so lange** die Linie berührt, wie das Trefferfenster (±0,1 s) dauert. Was man sieht, ist also auch das, was gewertet wird. Kacheln außerhalb des Bildschirms werden übersprungen.

### 4. Wertung

- Bei einem Tastendruck sucht `BeatRound.press(_:at:)` die **zeitlich nächste Note**. Treffer ist, wenn der Buchstabe stimmt **und** der Abstand ≤ `hitWindow` ist.
- Eine bereits bewertete Note lässt sich nicht nachträglich korrigieren.
- `markMissedNotes(at:)` wertet Noten, die das Trefferfenster verlassen haben, als `.bad`, und zwar nur einmal.
- Die Zeit des Tastendrucks kommt aus `Date.now`, nicht aus dem letzten Frame. Eingaben zwischen zwei Frames werden so exakt gewertet.

### 5. Tastatur ohne Ruckeln

`onKeyPress()` ließ die Animation bei Tastendrücken ruckeln. Deshalb liest das Spiel die Tastatur mit einem lokalen `NSEvent`-Monitor:

- Nur **Buchstaben** während eines laufenden Spiels werden abgefangen.
- **⌘-Shortcuts** und alle anderen Events gehen normal an das System weiter.

## Ideen für Erweiterungen

- **Home-Row-Modus:** nur `ASDFJKL` als Alphabet
- **Leichter Modus:** nur jeden zweiten Beat als Note (die Lichter folgen weiter allen Beats)
- **Feinere Wertung:** Bonus für Treffer nahe am exakten Beat
- **Streaks** für Treffer in Folge
- **Persönliche Bestleistung** pro Song
- Weitere Bewertungsstufen, dabei nicht nur auf Farbe setzen (Barrierefreiheit)

## Credits

Konzept, Tutorial und Code: **Paul Hudson**, [Hacking with Swift+](https://www.hackingwithswift.com/plus). Es gelten die [Code-Lizenzbedingungen](https://www.hackingwithswift.com/license) von Hacking with Swift.
