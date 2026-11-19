# ⌨️ Mac Stenography (Plover) Quick Reference & Beginner Guide

A complete guide for writing stenography on a built-in Mac QWERTY keyboard using Plover and Arpeggiate mode.

---

## 1. Keyboard Layout & Finger Assignments

```text
Steno:     #   #   #   #   #   #   #   #   #   #   #   #
Mac:       1   2   3   4   5   6   7   8   9   0   -   =

Steno:     S-  T-  P-  H-  *   *   -F  -P  -L  -T  -D
Mac:       Q   W   E   R   T   Y   U   I   O   P   [

Steno:     S-  K-  W-  R-  *   *   -R  -B  -G  -S  -Z
Mac:       A   S   D   F   G   H   J   K   L   ;   '

Thumbs:           A-  O-           -E  -U
Mac:              C   V            N   M

Commit:                       SPACEBAR
```

### Finger Positions
* **Left Hand:**
  * **Pinky:** `Q` / `A` (`S-`)
  * **Ring:** `W` (`T-`), `S` (`K-`)
  * **Middle:** `E` (`P-`), `D` (`W-`)
  * **Index:** `R` (`H-`), `F` (`R-`)
* **Thumbs:**
  * **Left Thumb:** `C` (`A-`), `V` (`O-`)
  * **Right Thumb:** `N` (`-E`), `M` (`-U`)
* **Right Hand:**
  * **Index:** `U` (`-F`), `J` (`-R`)
  * **Middle:** `I` (`-P`), `K` (`-B`)
  * **Ring:** `O` (`-L`), `L` (`-G`)
  * **Pinky:** `P` (`-T`), `;` (`-S`), `[` (`-D`), `'` (`-Z`)

---

## 2. How to Type with Arpeggiate Mode

Because MacBook keyboards lack NKRO (N-Key Rollover), pressing 3+ keys at the exact same millisecond will jam the hardware. **Arpeggiate** solves this:

1. **Roll your keys**: Press the letters of the chord one after another in quick succession.
2. **Tap Spacebar**: Spacebar is configured as your chord commit trigger. Plover combines all keys rolled since the last stroke and outputs the word.
3. **Toggle Output**: Press **`⌘ .`** (Command + Period) to instantly switch between Steno mode and normal QWERTY typing.

---

## 3. Essential Top Briefs

| Word | Steno Chord | Mac QWERTY Keys | Arpeggiate Sequence |
| :--- | :--- | :--- | :--- |
| **the** | `T` | `W` | `W` $\rightarrow$ `Space` |
| **of** | `-F` | `U` | `U` $\rightarrow$ `Space` |
| **and** | `SKP` | `Q + S + E` | `Q` $\rightarrow$ `S` $\rightarrow$ `E` $\rightarrow$ `Space` |
| **to** | `TO` | `W + V` | `W` $\rightarrow$ `V` $\rightarrow$ `Space` |
| **in** | `TPH` | `W + E + R` | `W` $\rightarrow$ `E` $\rightarrow$ `R` $\rightarrow$ `Space` |
| **is** | `S` | `Q` | `Q` $\rightarrow$ `Space` |
| **you** | `U` | `M` | `M` $\rightarrow$ `Space` |
| **that** | `THA` | `W + R + C` | `W` $\rightarrow$ `R` $\rightarrow$ `C` $\rightarrow$ `Space` |
| **it** | `T` | `P` | `P` $\rightarrow$ `Space` |
| **for** | `TP-R` | `W + E + J` | `W` $\rightarrow$ `E` $\rightarrow$ `J` $\rightarrow$ `Space` |
| **with** | `W` | `D` | `D` $\rightarrow$ `Space` |
| **can** | `K` | `S` | `S` $\rightarrow$ `Space` |
| **will** | `HR` | `R + F` | `R` $\rightarrow$ `F` $\rightarrow$ `Space` |
| **have** | `SR` | `Q + F` | `Q` $\rightarrow$ `F` $\rightarrow$ `Space` |
| **something** | `S-G` | `Q + L` | `Q` $\rightarrow$ `L` $\rightarrow$ `Space` |

---

## 4. Navigation & Editing Controls

| Action | Steno Chord | Mac QWERTY Keys |
| :--- | :--- | :--- |
| **Return / Enter** | `R*R` | `F + T + J` $\rightarrow$ `Space` |
| **Backspace** | `PW*FP` | `E + D + T + U + I` $\rightarrow$ `Space` |
| **Delete** | `TK*EL` | `W + S + T + N + O` $\rightarrow$ `Space` |
| **Escape** | `TPEFBG` | `W + E + U + K + L` $\rightarrow$ `Space` |
| **Tab** | `TA*B` | `W + C + T + K` $\rightarrow$ `Space` |
| **Left Arrow** | `STPH-R` | `Q + W + E + R + J` $\rightarrow$ `Space` |
| **Right Arrow** | `STPH-G` | `Q + W + E + R + L` $\rightarrow$ `Space` |
| **Up Arrow** | `STPH-P` | `Q + W + E + R + I` $\rightarrow$ `Space` |
| **Down Arrow** | `STPH-B` | `Q + W + E + R + K` $\rightarrow$ `Space` |

---

## 5. Developer & Terminal Briefs

| Command / Word | Steno Chord | Mac QWERTY Keys |
| :--- | :--- | :--- |
| **git** | `TKPW*EUT` | `W + S + E + D + T + N + M + P` |
| **return** | `RURPB` | `F + M + J + P + K` |
| **function** | `TP-PBGS` | `W + E + P + K + L + ;` |
| **true** | `TRAOU` | `W + F + C + V + M` |
| **false** | `TPALS` | `W + E + C + O + ;` |
| **let** | `HRET` | `R + F + N + P` |
| **error** | `ROER` | `F + V + N + J` |
| **test** | `TEFT` | `W + N + U + P` |
| **log** | `HROUG` | `R + F + V + M + L` |

---

## 6. Daily 15-Minute Learning Routine

1. **Launch Steno Companion**:
   * Open Raycast $\rightarrow$ `Steno Visual Companion` (or run `~/.dotfiles/scripts/steno-hud.sh`).
   * Keep it floating next to your workspace.
2. **Warmup (5 mins)**:
   * Click through the **Top 100** tab.
   * Stroke 10 words, watching the virtual keys light up.
3. **Drill (10 mins)**:
   * Open [Typey Type](https://typey-type.web.app/) in your browser.
   * Complete 2 lessons on single-syllable words and top briefs.
4. **During Work**:
   * Keep Plover output **OFF** (`⌘ .`) when coding fast.
   * Toggle **ON** (`⌘ .`) when writing low-pressure Slack messages or notes.
   * If stuck on any word: Open Raycast $\rightarrow$ `Steno Lookup <word>`.

