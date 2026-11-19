import Cocoa

// ==============================================================================
// 🚀 Native macOS Steno HUD: Live Keyboard with Alphabet Sound Mapping
// Shows where all "other sounds" (B, D, F, G, J, K, L, M, N, V, X, Z, etc.) are formed
// directly on the live visual keyboard, completely clean, compact, and silent.
// ==============================================================================

// Terminate previous instance to act as a toggle
let myPID = getpid()
let killTask = Process()
killTask.launchPath = "/bin/sh"
killTask.arguments = ["-c", "pgrep -x steno-hud | grep -v \(myPID) | xargs kill -9 2>/dev/null || true"]
try? killTask.run()
killTask.waitUntilExit()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Load Plover Dictionaries
var chordToWord: [String: String] = [:]
var wordToChords: [String: [String]] = [:]

func loadDictionaries() {
    let dictPaths = [
        ("~/Library/Application Support/plover/user.json" as NSString).expandingTildeInPath,
        ("~/Library/Application Support/plover/main.json" as NSString).expandingTildeInPath,
        ("~/Library/Application Support/plover/commands.json" as NSString).expandingTildeInPath
    ]
    for p in dictPaths {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: p)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            for (chord, word) in json {
                if chordToWord[chord] == nil {
                    chordToWord[chord] = word
                }
                let clean = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty {
                    if wordToChords[clean] == nil {
                        wordToChords[clean] = []
                    }
                    if !wordToChords[clean]!.contains(chord) {
                        wordToChords[clean]!.append(chord)
                    }
                }
            }
        }
    }
}
loadDictionaries()

// Steno Alphabet / Phonetic Sounds Reference (from official Plover cheat sheet)
struct StenoSoundInfo {
    let letter: String
    let leftSteno: String
    let leftKeys: [String]
    let rightSteno: String
    let rightKeys: [String]
    let hint: String
}

let alphabetSounds: [StenoSoundInfo] = [
    StenoSoundInfo(letter: "A", leftSteno: "A-", leftKeys: ["C"], rightSteno: "—", rightKeys: [], hint: "Vowel: Left Thumb [C]"),
    StenoSoundInfo(letter: "B", leftSteno: "PW-", leftKeys: ["E", "D"], rightSteno: "-B", rightKeys: ["K"], hint: "Left: PW [E+D] | Right: -B [K]"),
    StenoSoundInfo(letter: "C", leftSteno: "KR-", leftKeys: ["S", "F"], rightSteno: "—", rightKeys: [], hint: "Left: KR [S+F] (Hard C sound)"),
    StenoSoundInfo(letter: "D", leftSteno: "TK-", leftKeys: ["W", "S"], rightSteno: "-D", rightKeys: ["["], hint: "Left: TK [W+S] | Right: -D [[]"),
    StenoSoundInfo(letter: "E", leftSteno: "-E", leftKeys: ["N"], rightSteno: "—", rightKeys: [], hint: "Vowel: Right Thumb [N]"),
    StenoSoundInfo(letter: "F", leftSteno: "TP-", leftKeys: ["W", "E"], rightSteno: "-F", rightKeys: ["U"], hint: "Left: TP [W+E] | Right: -F [U]"),
    StenoSoundInfo(letter: "G", leftSteno: "TKPW-", leftKeys: ["W", "S", "E", "D"], rightSteno: "-G", rightKeys: ["L"], hint: "Left: TKPW [W+S+E+D] | Right: -G [L]"),
    StenoSoundInfo(letter: "H", leftSteno: "H-", leftKeys: ["R"], rightSteno: "—", rightKeys: [], hint: "Left: H [R] (Initial H)"),
    StenoSoundInfo(letter: "I", leftSteno: "EU", leftKeys: ["N", "M"], rightSteno: "—", rightKeys: [], hint: "Vowel: Thumbs [N+M] (Short I sound)"),
    StenoSoundInfo(letter: "J", leftSteno: "SKWR-", leftKeys: ["Q", "S", "D", "F"], rightSteno: "-PBLG", rightKeys: ["I", "K", "O", "L"], hint: "Left: SKWR [Q+S+D+F] | Right: -PBLG [I+K+O+L]"),
    StenoSoundInfo(letter: "K", leftSteno: "K-", leftKeys: ["S"], rightSteno: "-BG", rightKeys: ["K", "L"], hint: "Left: K [S] | Right: -BG [K+L]"),
    StenoSoundInfo(letter: "L", leftSteno: "HR-", leftKeys: ["R", "F"], rightSteno: "-L", rightKeys: ["O"], hint: "Left: HR [R+F] | Right: -L [O]"),
    StenoSoundInfo(letter: "M", leftSteno: "PH-", leftKeys: ["E", "R"], rightSteno: "-PL", rightKeys: ["I", "O"], hint: "Left: PH [E+R] | Right: -PL [I+O]"),
    StenoSoundInfo(letter: "N", leftSteno: "TPH-", leftKeys: ["W", "E", "R"], rightSteno: "-PB", rightKeys: ["I", "K"], hint: "Left: TPH [W+E+R] | Right: -PB [I+K]"),
    StenoSoundInfo(letter: "O", leftSteno: "O-", leftKeys: ["V"], rightSteno: "—", rightKeys: [], hint: "Vowel: Left Thumb [V]"),
    StenoSoundInfo(letter: "P", leftSteno: "P-", leftKeys: ["E"], rightSteno: "-P", rightKeys: ["I"], hint: "Left: P [E] | Right: -P [I]"),
    StenoSoundInfo(letter: "Q", leftSteno: "KW-", leftKeys: ["S", "D"], rightSteno: "—", rightKeys: [], hint: "Left: KW [S+D] (Qu sound)"),
    StenoSoundInfo(letter: "R", leftSteno: "R-", leftKeys: ["F"], rightSteno: "-R", rightKeys: ["J"], hint: "Left: R [F] | Right: -R [J]"),
    StenoSoundInfo(letter: "S", leftSteno: "S-", leftKeys: ["Q"], rightSteno: "-S", rightKeys: [";"], hint: "Left: S [Q or A] | Right: -S [;]"),
    StenoSoundInfo(letter: "T", leftSteno: "T-", leftKeys: ["W"], rightSteno: "-T", rightKeys: ["P"], hint: "Left: T [W] | Right: -T [P]"),
    StenoSoundInfo(letter: "U", leftSteno: "-U", leftKeys: ["M"], rightSteno: "—", rightKeys: [], hint: "Vowel: Right Thumb [M]"),
    StenoSoundInfo(letter: "V", leftSteno: "SR-", leftKeys: ["Q", "F"], rightSteno: "*F", rightKeys: ["T", "U"], hint: "Left: SR [Q+F] | Right: *F [T+U]"),
    StenoSoundInfo(letter: "W", leftSteno: "W-", leftKeys: ["D"], rightSteno: "—", rightKeys: [], hint: "Left: W [D] (Initial W)"),
    StenoSoundInfo(letter: "X", leftSteno: "KP-", leftKeys: ["S", "E"], rightSteno: "-BGS", rightKeys: ["K", "L", ";"], hint: "Left: KP [S+E] | Right: -BGS [K+L+;]"),
    StenoSoundInfo(letter: "Y", leftSteno: "KWR-", leftKeys: ["S", "D", "F"], rightSteno: "—", rightKeys: [], hint: "Left: KWR [S+D+F]"),
    StenoSoundInfo(letter: "Z", leftSteno: "S*-", leftKeys: ["Q", "T"], rightSteno: "-Z", rightKeys: ["'"], hint: "Left: S* [Q+T] | Right: -Z [']")
]

// Chord to Sound Name Lookup
let chordToSoundName: [String: String] = [
    "PW": "Sound: B (Initial)", "PW-": "Sound: B (Initial)", "-B": "Sound: B (Final)",
    "TK": "Sound: D (Initial)", "TK-": "Sound: D (Initial)", "-D": "Sound: D (Final)",
    "TP": "Sound: F (Initial)", "TP-": "Sound: F (Initial)", "-F": "Sound: F (Final)",
    "TKPW": "Sound: G (Initial)", "TKPW-": "Sound: G (Initial)", "-G": "Sound: G (Final)",
    "SKWR": "Sound: J (Initial)", "SKWR-": "Sound: J (Initial)", "-PBLG": "Sound: J (Final)",
    "K": "Sound: K (Initial)", "K-": "Sound: K (Initial)", "-BG": "Sound: K (Final)",
    "HR": "Sound: L (Initial)", "HR-": "Sound: L (Initial)", "-L": "Sound: L (Final)",
    "PH": "Sound: M (Initial)", "PH-": "Sound: M (Initial)", "-PL": "Sound: M (Final)",
    "TPH": "Sound: N (Initial)", "TPH-": "Sound: N (Initial)", "-PB": "Sound: N (Final)",
    "SR": "Sound: V (Initial)", "SR-": "Sound: V (Initial)", "*F": "Sound: V (Final)",
    "KP": "Sound: X (Initial)", "KP-": "Sound: X (Initial)", "-BGS": "Sound: X (Final)",
    "S*": "Sound: Z (Initial)", "S*-": "Sound: Z (Initial)", "-Z": "Sound: Z (Final)",
    "KR": "Sound: C (Hard C)", "KR-": "Sound: C (Hard C)",
    "KW": "Sound: Q (Qu)", "KW-": "Sound: Q (Qu)",
    "KWR": "Sound: Y", "KWR-": "Sound: Y",
    "EU": "Vowel: I",
    "A": "Vowel: A", "A-": "Vowel: A",
    "O": "Vowel: O", "O-": "Vowel: O",
    "E": "Vowel: E", "-E": "Vowel: E",
    "U": "Vowel: U", "-U": "Vowel: U",
    "S": "Sound: S (Initial)", "S-": "Sound: S (Initial)", "-S": "Sound: S (Final)",
    "T": "Sound: T (Initial)", "T-": "Sound: T (Initial)", "-T": "Sound: T (Final)",
    "P": "Sound: P (Initial)", "P-": "Sound: P (Initial)", "-P": "Sound: P (Final)",
    "R": "Sound: R (Initial)", "R-": "Sound: R (Initial)", "-R": "Sound: R (Final)",
    "H": "Sound: H (Initial)", "H-": "Sound: H (Initial)",
    "W": "Sound: W (Initial)", "W-": "Sound: W (Initial)"
]

// Chord to Alphabet Letter Mapping (Both left-side & right-side chords)
let chordToLetter: [String: String] = [
    "PW": "B", "PW-": "B", "-B": "B",
    "TK": "D", "TK-": "D", "-D": "D",
    "TP": "F", "TP-": "F", "-F": "F",
    "TKPW": "G", "TKPW-": "G", "-G": "G",
    "SKWR": "J", "SKWR-": "J", "-PBLG": "J",
    "K": "K", "K-": "K", "-BG": "K",
    "HR": "L", "HR-": "L", "-L": "L",
    "PH": "M", "PH-": "M", "-PL": "M",
    "TPH": "N", "TPH-": "N", "-PB": "N",
    "SR": "V", "SR-": "V", "*F": "V",
    "KP": "X", "KP-": "X", "-BGS": "X",
    "S*": "Z", "S*-": "Z", "-Z": "Z",
    "KR": "C", "KR-": "C",
    "KW": "Q", "KW-": "Q",
    "KWR": "Y", "KWR-": "Y",
    "EU": "I",
    "A": "A", "A-": "A",
    "O": "O", "O-": "O",
    "E": "E", "-E": "E",
    "U": "U", "-U": "U",
    "S": "S", "S-": "S", "-S": "S",
    "T": "T", "T-": "T", "-T": "T",
    "P": "P", "P-": "P", "-P": "P",
    "R": "R", "R-": "R", "-R": "R",
    "H": "H", "H-": "H",
    "W": "W", "W-": "W"
]

// Convert Set of Mac QWERTY keys to Steno chord
func keysToChord(_ keys: Set<String>) -> String {
    var left = ""
    if keys.contains("Q") || keys.contains("A") { left += "S" }
    if keys.contains("W") { left += "T" }
    if keys.contains("S") { left += "K" }
    if keys.contains("E") { left += "P" }
    if keys.contains("D") { left += "W" }
    if keys.contains("R") { left += "H" }
    if keys.contains("F") { left += "R" }
    
    var middle = ""
    if keys.contains("C") { middle += "A" }
    if keys.contains("V") { middle += "O" }
    if keys.contains("T") || keys.contains("G") || keys.contains("Y") || keys.contains("H") { middle += "*" }
    if keys.contains("N") { middle += "E" }
    if keys.contains("M") { middle += "U" }
    
    var right = ""
    if keys.contains("U") { right += "F" }
    if keys.contains("J") { right += "R" }
    if keys.contains("I") { right += "P" }
    if keys.contains("K") { right += "B" }
    if keys.contains("O") { right += "L" }
    if keys.contains("L") { right += "G" }
    if keys.contains("P") { right += "T" }
    if keys.contains(";") { right += "S" }
    if keys.contains("[") { right += "D" }
    if keys.contains("'") { right += "Z" }
    
    if middle.isEmpty && !right.isEmpty {
        return "\(left)-\(right)"
    } else {
        return "\(left)\(middle)\(right)"
    }
}

// Convert Chord to Mac keys
func chordToMacKeys(_ chord: String) -> String {
    let orderLeft: [(Character, String)] = [("S", "Q"), ("T", "W"), ("K", "S"), ("P", "E"), ("W", "D"), ("H", "R"), ("R", "F")]
    let orderRight: [(Character, String)] = [("F", "U"), ("R", "J"), ("P", "I"), ("B", "K"), ("L", "O"), ("G", "L"), ("T", "P"), ("S", ";"), ("D", "["), ("Z", "'")]
    
    var res: [String] = []
    let strokes = chord.split(separator: "/")
    for stroke in strokes {
        var sKeys: [String] = []
        let hasHyphen = stroke.contains("-")
        let parts = stroke.split(separator: "-")
        let leftPart = String(parts[0])
        
        var idx = leftPart.startIndex
        for (stenoChar, qKey) in orderLeft {
            if idx < leftPart.endIndex && leftPart[idx] == stenoChar {
                sKeys.append(qKey)
                idx = leftPart.index(after: idx)
            }
        }
        if idx < leftPart.endIndex && leftPart[idx] == "A" { sKeys.append("C"); idx = leftPart.index(after: idx) }
        if idx < leftPart.endIndex && leftPart[idx] == "O" { sKeys.append("V"); idx = leftPart.index(after: idx) }
        if idx < leftPart.endIndex && leftPart[idx] == "*" { sKeys.append("T"); idx = leftPart.index(after: idx) }
        if idx < leftPart.endIndex && leftPart[idx] == "E" { sKeys.append("N"); idx = leftPart.index(after: idx) }
        if idx < leftPart.endIndex && leftPart[idx] == "U" { sKeys.append("M"); idx = leftPart.index(after: idx) }
        
        let rightPart = hasHyphen && parts.count > 1 ? String(parts[1]) : String(leftPart[idx...])
        var rIdx = rightPart.startIndex
        for (stenoChar, qKey) in orderRight {
            if rIdx < rightPart.endIndex && rightPart[rIdx] == stenoChar {
                sKeys.append(qKey)
                rIdx = rightPart.index(after: rIdx)
            }
        }
        sKeys.append("Space")
        res.append(sKeys.joined(separator: " + "))
    }
    return res.joined(separator: " / ")
}

enum ActiveTab: Int {
    case keyboard = 1
    case lookup = 2
}

class CustomPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class UnifiedStenoView: NSView {
    var currentTab: ActiveTab = .keyboard
    
    // Tab 1 (Keyboard & Sounds) State
    var activePhysKeys: Set<String> = []
    var rolledBuffer: [String] = []
    var currentChord: String = ""
    var liveSuggestions: [String] = []
    var lastCommitted: String = "Ready"
    var selectedSound: StenoSoundInfo? = nil // Optional inspected sound from strip
    
    // Tab 2 (Lookup) State
    var searchQuery: String = ""
    var lookupResults: [(word: String, chord: String, macKeys: String)] = []
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers ?? ""
        let upperChars = chars.uppercased()
        let keyCode = event.keyCode
        
        // Escape / Cmd+W to close
        if keyCode == 53 || (event.modifierFlags.contains(.command) && upperChars == "W") {
            if selectedSound != nil {
                selectedSound = nil
                needsDisplay = true
                return
            }
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.12
                self.window?.animator().alphaValue = 0
            }, completionHandler: {
                exit(0)
            })
            return
        }
        
        // Tab key: Toggle between Tab 1 and Tab 2
        if keyCode == 48 {
            currentTab = (currentTab == .keyboard) ? .lookup : .keyboard
            needsDisplay = true
            return
        }
        
        // Cmd+1 / Cmd+2
        if event.modifierFlags.contains(.command) {
            if chars == "1" { currentTab = .keyboard; needsDisplay = true; return }
            if chars == "2" { currentTab = .lookup; needsDisplay = true; return }
        }
        
        // Option + Letter: Direct Alphabet Sound Inspector (e.g. Opt+B, Opt+Z)
        if event.modifierFlags.contains(.option) && !upperChars.isEmpty {
            if let sound = alphabetSounds.first(where: { $0.letter == upperChars }) {
                selectedSound = (selectedSound?.letter == sound.letter) ? nil : sound
                needsDisplay = true
                return
            }
        }
        
        // TAB 1: Live Keyboard
        if currentTab == .keyboard {
            // Direct 1 or 2 switch if buffer empty
            if rolledBuffer.isEmpty {
                if chars == "1" { currentTab = .keyboard; needsDisplay = true; return }
                if chars == "2" { currentTab = .lookup; needsDisplay = true; return }
                
                // If user presses non-steno letters (e.g. B, X, Z) directly, inspect that sound!
                if ["B", "X", "Z"].contains(upperChars) {
                    if let sound = alphabetSounds.first(where: { $0.letter == upperChars }) {
                        selectedSound = (selectedSound?.letter == sound.letter) ? nil : sound
                        needsDisplay = true
                        return
                    }
                }
            }
            
            // Spacebar: Commit chord
            if keyCode == 49 {
                activePhysKeys.insert("SPACE")
                if !rolledBuffer.isEmpty {
                    let chord = keysToChord(Set(rolledBuffer))
                    if let trans = chordToWord[chord] {
                        lastCommitted = trans
                    } else if let sound = chordToSoundName[chord] {
                        lastCommitted = sound
                    } else {
                        lastCommitted = chord
                    }
                    rolledBuffer.removeAll()
                    currentChord = ""
                    liveSuggestions.removeAll()
                }
                needsDisplay = true
                return
            }
            
            // Physical Key Down
            if !upperChars.isEmpty && "QWERTYUIOP[ASDFGHJKL;'CVNM".contains(upperChars) {
                activePhysKeys.insert(upperChars)
                if !rolledBuffer.contains(upperChars) {
                    rolledBuffer.append(upperChars)
                }
                updateLiveKeyboardSuggestions()
            }
            needsDisplay = true
            return
        }
        
        // TAB 2: Word Lookup
        if currentTab == .lookup {
            if searchQuery.isEmpty && chars == "1" {
                currentTab = .keyboard
                needsDisplay = true
                return
            }
            if keyCode == 51 { // Backspace
                if !searchQuery.isEmpty {
                    searchQuery.removeLast()
                    updateWordLookup()
                }
                needsDisplay = true
                return
            }
            if !chars.isEmpty && chars.rangeOfCharacter(from: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-*/"))) != nil {
                searchQuery += chars.lowercased()
                updateWordLookup()
                needsDisplay = true
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers?.uppercased() ?? ""
        if event.keyCode == 49 {
            activePhysKeys.remove("SPACE")
        } else {
            activePhysKeys.remove(chars)
        }
        needsDisplay = true
    }
    
    func updateLiveKeyboardSuggestions() {
        guard !rolledBuffer.isEmpty else {
            currentChord = ""
            liveSuggestions.removeAll()
            return
        }
        currentChord = keysToChord(Set(rolledBuffer))
        var list: [String] = []
        
        // Check exact match
        if let exact = chordToWord[currentChord] {
            list.append(exact)
        }
        
        // Check sound match
        if let sound = chordToSoundName[currentChord] {
            if !list.contains(sound) {
                list.append(sound)
            }
        }
        
        // Check prefix completions
        for (c, w) in chordToWord {
            if c != currentChord && c.hasPrefix(currentChord) {
                if !list.contains(w) {
                    list.append(w)
                    if list.count >= 4 { break }
                }
            }
        }
        liveSuggestions = list
    }
    
    func updateWordLookup() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            lookupResults.removeAll()
            return
        }
        var results: [(word: String, chord: String, macKeys: String)] = []
        
        if let word = chordToWord[q.uppercased()] {
            let mKeys = chordToMacKeys(q.uppercased())
            results.append((word: word, chord: q.uppercased(), macKeys: mKeys))
        }
        if let chords = wordToChords[q] {
            let sorted = chords.sorted { ($0.contains("/") ? 1 : 0, $0.count) < ($1.contains("/") ? 1 : 0, $1.count) }
            for c in sorted.prefix(4) {
                let mKeys = chordToMacKeys(c)
                results.append((word: q, chord: c, macKeys: mKeys))
            }
        }
        if results.count < 4 {
            for (w, clist) in wordToChords {
                if w.contains(q) && w != q {
                    let sorted = clist.sorted { ($0.contains("/") ? 1 : 0, $0.count) < ($1.contains("/") ? 1 : 0, $1.count) }
                    if let firstChord = sorted.first {
                        let mKeys = chordToMacKeys(firstChord)
                        results.append((word: w, chord: firstChord, macKeys: mKeys))
                        if results.count >= 5 { break }
                    }
                }
            }
        }
        lookupResults = results
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        // Tab buttons
        let tabY = bounds.height - 30
        addCursorRect(NSRect(x: 16, y: tabY, width: 115, height: 20), cursor: .pointingHand)
        addCursorRect(NSRect(x: 136, y: tabY, width: 115, height: 20), cursor: .pointingHand)
        
        // Close button
        addCursorRect(NSRect(x: bounds.width - 28, y: bounds.height - 28, width: 18, height: 18), cursor: .pointingHand)
        
        // Alphabet sound strip pills
        if currentTab == .keyboard {
            let stripX: CGFloat = 16
            let stripY = bounds.height - 56
            let totalW = bounds.width - 32
            let pillW = totalW / CGFloat(alphabetSounds.count)
            let pillH: CGFloat = 19
            for i in 0..<alphabetSounds.count {
                let px = stripX + CGFloat(i) * pillW
                let pr = NSRect(x: px + 1, y: stripY, width: pillW - 2, height: pillH)
                addCursorRect(pr, cursor: .pointingHand)
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        
        // Close button
        let closeRect = NSRect(x: bounds.width - 28, y: bounds.height - 28, width: 18, height: 18)
        if closeRect.contains(pt) {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.12
                self.window?.animator().alphaValue = 0
            }, completionHandler: {
                exit(0)
            })
            return
        }
        
        // Tab buttons clicked
        let tabY = bounds.height - 32
        if pt.y >= tabY && pt.y <= tabY + 22 {
            if pt.x >= 16 && pt.x <= 130 {
                currentTab = .keyboard
                needsDisplay = true
                return
            } else if pt.x >= 135 && pt.x <= 265 {
                currentTab = .lookup
                needsDisplay = true
                return
            }
        }
        
        // If in Tab 1: Check Alphabet Sound Strip Click
        if currentTab == .keyboard {
            let stripX: CGFloat = 16
            let stripY = bounds.height - 56
            let pillH: CGFloat = 19
            let totalW = bounds.width - 32
            let count = alphabetSounds.count
            let pillW = totalW / CGFloat(count)
            
            if pt.y >= stripY && pt.y <= stripY + pillH && pt.x >= stripX && pt.x <= stripX + totalW {
                let idx = Int((pt.x - stripX) / pillW)
                if idx >= 0 && idx < count {
                    let clicked = alphabetSounds[idx]
                    if selectedSound?.letter == clicked.letter {
                        selectedSound = nil // Deselect on second click
                    } else {
                        selectedSound = clicked
                    }
                    needsDisplay = true
                    return
                }
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // 1. Top Navigation
        drawTabBar()
        
        // 2. Active Tab Content
        if currentTab == .keyboard {
            drawTab1KeyboardWithSounds()
        } else {
            drawTab2Lookup()
        }
    }
    
    func drawTabBar() {
        drawTabPill(title: "[1] Live Keyboard", isActive: currentTab == .keyboard, rect: NSRect(x: 16, y: bounds.height - 30, width: 115, height: 20))
        drawTabPill(title: "[2] Word Lookup", isActive: currentTab == .lookup, rect: NSRect(x: 136, y: bounds.height - 30, width: 115, height: 20))
        
        let hintAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: NSColor(white: 0.5, alpha: 1.0)
        ]
        ("Press [1] or [2]  •  [Tab] Toggle  •  [Esc] Close" as NSString).draw(at: NSPoint(x: 265, y: bounds.height - 26), withAttributes: hintAttr)
        
        let closeAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: NSColor(white: 0.5, alpha: 1.0)
        ]
        ("✕" as NSString).draw(at: NSPoint(x: bounds.width - 24, y: bounds.height - 26), withAttributes: closeAttr)
    }
    
    func drawTabPill(title: String, isActive: Bool, rect: NSRect) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 5, yRadius: 5)
        if isActive {
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.3).setFill()
            path.fill()
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.85).setStroke()
            path.lineWidth = 1.2
            path.stroke()
        } else {
            NSColor(white: 1.0, alpha: 0.06).setFill()
            path.fill()
        }
        let fontColor = isActive ? NSColor.white : NSColor(white: 0.65, alpha: 1.0)
        let attr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10.5, weight: isActive ? .bold : .medium),
            .foregroundColor: fontColor
        ]
        let sz = (title as NSString).size(withAttributes: attr)
        (title as NSString).draw(at: NSPoint(x: rect.midX - sz.width / 2, y: rect.midY - sz.height / 2), withAttributes: attr)
    }
    
    // =========================================================================
    // TAB 1: LIVE KEYBOARD + STENO ALPHABET SOUND REFERENCE
    // =========================================================================
    func drawTab1KeyboardWithSounds() {
        // Find if current live rolled chord maps to an alphabet sound
        let activeLiveLetter = chordToLetter[currentChord]
        let activeSound = (activeLiveLetter != nil ? alphabetSounds.first(where: { $0.letter == activeLiveLetter }) : nil) ?? selectedSound
        
        // A. Sleek A-to-Z Sound Reference Strip (Highlighting both clicked sound & live rolled chord)
        let count = alphabetSounds.count
        let stripX: CGFloat = 16
        let stripY = bounds.height - 56
        let totalW = bounds.width - 32
        let pillW = totalW / CGFloat(count)
        let pillH: CGFloat = 19
        
        for (i, sound) in alphabetSounds.enumerated() {
            let px = stripX + CGFloat(i) * pillW
            let pr = NSRect(x: px + 1, y: stripY, width: pillW - 2, height: pillH)
            
            let isLive = (activeLiveLetter == sound.letter)
            let isSel = (selectedSound?.letter == sound.letter)
            
            let pPath = NSBezierPath(roundedRect: pr, xRadius: 4, yRadius: 4)
            if isLive {
                // Vibrant Electric Cyan glow when rolling this letter's steno keys
                NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.55).setFill()
                pPath.fill()
                NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0).setStroke()
                pPath.lineWidth = 1.6
                pPath.stroke()
            } else if isSel {
                // Luminous Gold glow when clicked or inspected
                NSColor(red: 0.98, green: 0.75, blue: 0.2, alpha: 0.4).setFill()
                pPath.fill()
                NSColor(red: 0.98, green: 0.75, blue: 0.2, alpha: 1.0).setStroke()
                pPath.lineWidth = 1.4
                pPath.stroke()
            } else {
                NSColor(white: 1.0, alpha: 0.06).setFill()
                pPath.fill()
            }
            
            let color: NSColor
            if isLive {
                color = .white
            } else if isSel {
                color = NSColor(red: 1.0, green: 0.88, blue: 0.35, alpha: 1.0)
            } else {
                color = NSColor(white: 0.75, alpha: 1.0)
            }
            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 10, weight: (isLive || isSel) ? .heavy : .bold),
                .foregroundColor: color
            ]
            let sz = (sound.letter as NSString).size(withAttributes: attr)
            (sound.letter as NSString).draw(at: NSPoint(x: pr.midX - sz.width / 2, y: pr.midY - sz.height / 2), withAttributes: attr)
        }
        
        // B. Active Sound Guide / Live Chord Info Banner
        let infoRect = NSRect(x: 16, y: bounds.height - 86, width: bounds.width - 32, height: 24)
        let bgPath = NSBezierPath(roundedRect: infoRect, xRadius: 5, yRadius: 5)
        NSColor(red: 0.1, green: 0.13, blue: 0.19, alpha: 0.85).setFill()
        bgPath.fill()
        
        if let sound = activeSound {
            // Active Alphabet Sound Hint
            let mode = (activeLiveLetter != nil) ? "Live Sound" : "Sound"
            let sText = "\(mode) '\(sound.letter)': \(sound.hint)"
            let sAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                .foregroundColor: (activeLiveLetter != nil) ? NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0) : NSColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
            ]
            (sText as NSString).draw(at: NSPoint(x: 24, y: bounds.height - 81), withAttributes: sAttr)
            
            if !liveSuggestions.isEmpty {
                var rightX = bounds.width - 24
                for (idx, sug) in liveSuggestions.prefix(3).enumerated().reversed() {
                    let isPrimary = (idx == 0)
                    let text = isPrimary ? "✓ \"\(sug)\"" : "\"\(sug)\""
                    let color = isPrimary ? NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1.0) : NSColor(white: 0.65, alpha: 1.0)
                    let attr: [NSAttributedString.Key: Any] = [
                        .font: NSFont.monospacedSystemFont(ofSize: isPrimary ? 10.5 : 9.5, weight: isPrimary ? .heavy : .medium),
                        .foregroundColor: color
                    ]
                    let sz = (text as NSString).size(withAttributes: attr)
                    rightX -= (sz.width + 8)
                    (text as NSString).draw(at: NSPoint(x: rightX, y: bounds.height - 81), withAttributes: attr)
                }
            } else {
                let legAttr: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 9.5, weight: .medium),
                    .foregroundColor: NSColor(white: 0.6, alpha: 1.0)
                ]
                ("■ Cyan: Left Steno  ■ Green: Right Steno" as NSString).draw(at: NSPoint(x: bounds.width - 230, y: bounds.height - 81), withAttributes: legAttr)
            }
        } else {
            // Live Stroke Buffer & Real-Time Suggestions
            let chordText = currentChord.isEmpty ? "Stroke Buffer: —" : "[\(rolledBuffer.joined(separator: "+"))] \(currentChord)"
            let chordColor = currentChord.isEmpty ? NSColor(white: 0.55, alpha: 1.0) : NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
            let cAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                .foregroundColor: chordColor
            ]
            (chordText as NSString).draw(at: NSPoint(x: 24, y: bounds.height - 81), withAttributes: cAttr)
            
            if !liveSuggestions.isEmpty {
                var rightX = bounds.width - 24
                for (idx, sug) in liveSuggestions.enumerated().reversed() {
                    let isPrimary = (idx == 0)
                    let text = isPrimary ? "✓ \"\(sug)\"" : "\"\(sug)\""
                    let color = isPrimary ? NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1.0) : NSColor(white: 0.6, alpha: 1.0)
                    let attr: [NSAttributedString.Key: Any] = [
                        .font: NSFont.monospacedSystemFont(ofSize: isPrimary ? 11 : 10, weight: isPrimary ? .heavy : .medium),
                        .foregroundColor: color
                    ]
                    let sz = (text as NSString).size(withAttributes: attr)
                    rightX -= (sz.width + 8)
                    (text as NSString).draw(at: NSPoint(x: rightX, y: bounds.height - 81), withAttributes: attr)
                }
            } else {
                let rAttr: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 10, weight: .medium),
                    .foregroundColor: NSColor(white: 0.45, alpha: 1.0)
                ]
                ("Last: \(lastCommitted)" as NSString).draw(at: NSPoint(x: bounds.width - 130, y: bounds.height - 81), withAttributes: rAttr)
            }
        }
        
        // C. Visual Keyboard Layout
        drawCompactKeyboardGrid(activeSound: activeSound)
    }
    
    func drawCompactKeyboardGrid(activeSound: StenoSoundInfo?) {
        let leftHighlight = Set(activeSound?.leftKeys ?? [])
        let rightHighlight = Set(activeSound?.rightKeys ?? [])
        
        let row1: [(steno: String, qwerty: String, zone: String)] = [
            ("S", "Q", "L"), ("T", "W", "L"), ("P", "E", "L"), ("H", "R", "L"), ("*", "T", "C"),
            ("*", "Y", "C"), ("F", "U", "R"), ("P", "I", "R"), ("L", "O", "R"), ("T", "P", "R"), ("D", "[", "R")
        ]
        let row2: [(steno: String, qwerty: String, zone: String)] = [
            ("S", "A", "L"), ("K", "S", "L"), ("W", "D", "L"), ("R", "F", "L"), ("*", "G", "C"),
            ("*", "H", "C"), ("R", "J", "R"), ("B", "K", "R"), ("G", "L", "R"), ("S", ";", "R"), ("Z", "'", "R")
        ]
        
        let keyW: CGFloat = 43
        let keyH: CGFloat = 38
        let spacing: CGFloat = 6
        let splitW: CGFloat = 16
        let totalRowW = CGFloat(11) * keyW + CGFloat(10) * spacing + splitW
        let startX = (bounds.width - totalRowW) / 2
        
        // Row 1
        var curX = startX
        let row1Y = bounds.height - 132
        for (i, k) in row1.enumerated() {
            if i == 5 { curX += splitW }
            let kr = NSRect(x: curX, y: row1Y, width: keyW, height: keyH)
            drawKeyCap(steno: k.steno, qwerty: k.qwerty, zone: k.zone, rect: kr,
                       isLeftGuide: leftHighlight.contains(k.qwerty),
                       isRightGuide: rightHighlight.contains(k.qwerty))
            curX += keyW + spacing
        }
        
        // Row 2
        curX = startX
        let row2Y = row1Y - keyH - spacing
        for (i, k) in row2.enumerated() {
            if i == 5 { curX += splitW }
            let kr = NSRect(x: curX, y: row2Y, width: keyW, height: keyH)
            drawKeyCap(steno: k.steno, qwerty: k.qwerty, zone: k.zone, rect: kr,
                       isLeftGuide: leftHighlight.contains(k.qwerty),
                       isRightGuide: rightHighlight.contains(k.qwerty))
            curX += keyW + spacing
        }
        
        // Thumbs
        let thumbW: CGFloat = 48
        let thumbH: CGFloat = 32
        let thumbY = row2Y - thumbH - 6
        let lThumbX = bounds.width / 2 - (thumbW * 2 + 10)
        
        drawKeyCap(steno: "A", qwerty: "C", zone: "T", rect: NSRect(x: lThumbX, y: thumbY, width: thumbW, height: thumbH),
                   isLeftGuide: leftHighlight.contains("C"), isRightGuide: false)
        drawKeyCap(steno: "O", qwerty: "V", zone: "T", rect: NSRect(x: lThumbX + thumbW + 6, y: thumbY, width: thumbW, height: thumbH),
                   isLeftGuide: leftHighlight.contains("V"), isRightGuide: false)
        
        let rThumbX = bounds.width / 2 + 10
        drawKeyCap(steno: "E", qwerty: "N", zone: "T", rect: NSRect(x: rThumbX, y: thumbY, width: thumbW, height: thumbH),
                   isLeftGuide: leftHighlight.contains("N"), isRightGuide: rightHighlight.contains("N"))
        drawKeyCap(steno: "U", qwerty: "M", zone: "T", rect: NSRect(x: rThumbX + thumbW + 6, y: thumbY, width: thumbW, height: thumbH),
                   isLeftGuide: leftHighlight.contains("M"), isRightGuide: rightHighlight.contains("M"))
        
        // Spacebar
        let spaceW: CGFloat = 200
        let spaceH: CGFloat = 22
        let spaceR = NSRect(x: bounds.width / 2 - spaceW / 2, y: 8, width: spaceW, height: spaceH)
        let isSpaceDown = activePhysKeys.contains("SPACE")
        
        let spPath = NSBezierPath(roundedRect: spaceR, xRadius: 5, yRadius: 5)
        if isSpaceDown {
            NSColor(red: 0.98, green: 0.75, blue: 0.2, alpha: 0.85).setFill()
            spPath.fill()
        } else {
            NSColor(white: 1.0, alpha: 0.08).setFill()
            spPath.fill()
            NSColor(red: 0.98, green: 0.75, blue: 0.2, alpha: 0.45).setStroke()
            spPath.lineWidth = 1.0
            spPath.stroke()
        }
        let spAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: isSpaceDown ? NSColor.black : NSColor(white: 0.85, alpha: 1.0)
        ]
        let spLabel = "SPACE (Commit)"
        let spSz = (spLabel as NSString).size(withAttributes: spAttr)
        (spLabel as NSString).draw(at: NSPoint(x: spaceR.midX - spSz.width / 2, y: spaceR.midY - spSz.height / 2), withAttributes: spAttr)
    }
    
    func drawKeyCap(steno: String, qwerty: String, zone: String, rect: NSRect, isLeftGuide: Bool = false, isRightGuide: Bool = false) {
        let isPhysDown = activePhysKeys.contains(qwerty)
        let isRolled = rolledBuffer.contains(qwerty)
        let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
        
        if isPhysDown {
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.95).setFill()
            path.fill()
            NSColor.white.setStroke()
            path.lineWidth = 1.8
            path.stroke()
        } else if isRolled {
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.45).setFill()
            path.fill()
            if isLeftGuide || isRightGuide {
                (isLeftGuide ? NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0) : NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1.0)).setStroke()
                path.lineWidth = 2.0
            } else {
                NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.9).setStroke()
                path.lineWidth = 1.4
            }
            path.stroke()
        } else if isLeftGuide {
            // Cyan Glow for Left Alphabet Sound
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.35).setFill()
            path.fill()
            NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.95).setStroke()
            path.lineWidth = 1.6
            path.stroke()
        } else if isRightGuide {
            // Green Glow for Right Alphabet Sound
            NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 0.35).setFill()
            path.fill()
            NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 0.95).setStroke()
            path.lineWidth = 1.6
            path.stroke()
        } else {
            NSColor(white: 1.0, alpha: 0.07).setFill()
            path.fill()
            
            let zColor: NSColor
            switch zone {
            case "L": zColor = NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.35)
            case "R": zColor = NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 0.35)
            case "T": zColor = NSColor(red: 0.98, green: 0.6, blue: 0.2, alpha: 0.35)
            default:  zColor = NSColor(red: 0.75, green: 0.5, blue: 0.98, alpha: 0.35)
            }
            zColor.setStroke()
            path.lineWidth = 1.0
            path.stroke()
        }
        
        let sColor: NSColor
        if isPhysDown {
            sColor = .black
        } else if isLeftGuide {
            sColor = NSColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0)
        } else if isRightGuide {
            sColor = NSColor(red: 0.5, green: 1.0, blue: 0.7, alpha: 1.0)
        } else if isRolled {
            sColor = NSColor(red: 0.6, green: 0.9, blue: 1.0, alpha: 1.0)
        } else {
            sColor = .white
        }
        let sAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .heavy),
            .foregroundColor: sColor
        ]
        let sSz = (steno as NSString).size(withAttributes: sAttr)
        (steno as NSString).draw(at: NSPoint(x: rect.midX - sSz.width / 2, y: rect.midY - sSz.height / 2 + 5), withAttributes: sAttr)
        
        let qColor = isPhysDown ? NSColor(white: 0.15, alpha: 1.0) : (isRolled || isLeftGuide || isRightGuide ? NSColor.white : NSColor(white: 0.6, alpha: 1.0))
        let qAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 9, weight: .bold),
            .foregroundColor: qColor
        ]
        let qSz = (qwerty as NSString).size(withAttributes: qAttr)
        (qwerty as NSString).draw(at: NSPoint(x: rect.midX - qSz.width / 2, y: rect.midY - qSz.height / 2 - 6), withAttributes: qAttr)
    }
    
    // =========================================================================
    // TAB 2: REAL-TIME WORD LOOKUP & SUGGESTIONS
    // =========================================================================
    func drawTab2Lookup() {
        let searchRect = NSRect(x: 16, y: bounds.height - 76, width: bounds.width - 32, height: 32)
        let sPath = NSBezierPath(roundedRect: searchRect, xRadius: 7, yRadius: 7)
        NSColor(red: 0.1, green: 0.13, blue: 0.19, alpha: 0.85).setFill()
        sPath.fill()
        NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.6).setStroke()
        sPath.lineWidth = 1.2
        sPath.stroke()
        
        let queryDisplay = searchQuery.isEmpty ? "Type word or chord (e.g. apple, something, S-G)..." : "\(searchQuery)_"
        let qColor = searchQuery.isEmpty ? NSColor(white: 0.45, alpha: 1.0) : NSColor.white
        let sAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold),
            .foregroundColor: qColor
        ]
        ("🔍 \(queryDisplay)" as NSString).draw(at: NSPoint(x: 28, y: bounds.height - 68), withAttributes: sAttr)
        
        let rowH: CGFloat = 34
        let maxRows = 4
        
        if lookupResults.isEmpty {
            let emptyAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: NSColor(white: 0.4, alpha: 1.0)
            ]
            let hint = searchQuery.isEmpty ? "Start typing letters to see instant chord & Mac key suggestions" : "No matching steno translations found"
            (hint as NSString).draw(at: NSPoint(x: 28, y: bounds.height - 116), withAttributes: emptyAttr)
            return
        }
        
        let startY = bounds.height - 120
        for (idx, item) in lookupResults.prefix(maxRows).enumerated() {
            let ry = startY - CGFloat(idx) * (rowH + 4)
            let rRect = NSRect(x: 16, y: ry, width: bounds.width - 32, height: rowH)
            
            let rPath = NSBezierPath(roundedRect: rRect, xRadius: 6, yRadius: 6)
            let isFirst = (idx == 0)
            if isFirst {
                NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 0.12).setFill()
                rPath.fill()
                NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 0.45).setStroke()
                rPath.lineWidth = 1.0
                rPath.stroke()
            } else {
                NSColor(white: 1.0, alpha: 0.05).setFill()
                rPath.fill()
            }
            
            // Word
            let wAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12.5, weight: isFirst ? .heavy : .bold),
                .foregroundColor: isFirst ? NSColor.white : NSColor(white: 0.85, alpha: 1.0)
            ]
            (item.word as NSString).draw(at: NSPoint(x: 28, y: ry + 9), withAttributes: wAttr)
            
            // Steno Chord Badge
            let cAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 11.5, weight: .heavy),
                .foregroundColor: isFirst ? NSColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1.0) : NSColor(red: 0.98, green: 0.75, blue: 0.2, alpha: 1.0)
            ]
            ("Chord: \(item.chord)" as NSString).draw(at: NSPoint(x: 190, y: ry + 9), withAttributes: cAttr)
            
            // Mac Roll Sequence
            let mAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 10.5, weight: .bold),
                .foregroundColor: NSColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
            ]
            ("Mac Roll: [\(item.macKeys)]" as NSString).draw(at: NSPoint(x: 350, y: ry + 9), withAttributes: mAttr)
        }
    }
}

// Setup Clean Window Panel (620 x 280)
guard let screen = NSScreen.main else { exit(0) }
let screenFrame = screen.visibleFrame

let panelWidth: CGFloat = 620
let panelHeight: CGFloat = 280
let x = screenFrame.midX - panelWidth / 2
let y = screenFrame.minY + 60

let panel = CustomPanel(
    contentRect: NSRect(x: x, y: y, width: panelWidth, height: panelHeight),
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
panel.title = "Steno Visual HUD"
panel.level = .floating
panel.isOpaque = false
panel.backgroundColor = .clear
panel.hasShadow = true

let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
visualEffect.material = .hudWindow
visualEffect.blendingMode = .behindWindow
visualEffect.state = .active
visualEffect.wantsLayer = true
visualEffect.layer?.cornerRadius = 14
visualEffect.layer?.masksToBounds = true
visualEffect.layer?.borderColor = NSColor(white: 1.0, alpha: 0.16).cgColor
visualEffect.layer?.borderWidth = 1.0

let hudView = UnifiedStenoView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
visualEffect.addSubview(hudView)
panel.contentView = visualEffect
panel.makeKeyAndOrderFront(nil)
panel.makeFirstResponder(hudView)
NSApp.activate(ignoringOtherApps: true)
panel.alphaValue = 0

// Smooth entrance
NSAnimationContext.runAnimationGroup({ ctx in
    ctx.duration = 0.12
    panel.animator().alphaValue = 1.0
})

app.run()
