#!/usr/bin/env python3
"""
Steno Lookup CLI
Fast dictionary lookup for Plover stenotype chords with QWERTY mappings and visual finger charts.
"""

import sys
import os
import json
import re

DICTIONARY_PATHS = [
    os.path.expanduser("~/Library/Application Support/plover/user.json"),
    os.path.expanduser("~/Library/Application Support/plover/main.json"),
    os.path.expanduser("~/Library/Application Support/plover/commands.json")
]

KEY_INFO = {
    '#':  ('Number Bar', '1-0', '#', 'Top'),
    'S-': ('Left Pinky', 'Q/A', 'S', 'Left Top/Bot'),
    'T-': ('Left Ring', 'W', 'T', 'Left Top'),
    'K-': ('Left Ring', 'S', 'K', 'Left Bot'),
    'P-': ('Left Middle', 'E', 'P', 'Left Top'),
    'W-': ('Left Middle', 'D', 'W', 'Left Bot'),
    'H-': ('Left Index', 'R', 'H', 'Left Top'),
    'R-': ('Left Index', 'F', 'R', 'Left Bot'),
    'A-': ('Left Thumb', 'C', 'A', 'Thumb Left'),
    'O-': ('Left Thumb', 'V', 'O', 'Thumb Left'),
    '*':  ('Center Asterisk', 'T/Y/G/H', '*', 'Center'),
    '-E': ('Right Thumb', 'N', 'E', 'Thumb Right'),
    '-U': ('Right Thumb', 'M', 'U', 'Thumb Right'),
    '-F': ('Right Index', 'U', 'F', 'Right Top'),
    '-R': ('Right Index', 'J', 'R', 'Right Bot'),
    '-P': ('Right Middle', 'I', 'P', 'Right Top'),
    '-B': ('Right Middle', 'K', 'B', 'Right Bot'),
    '-L': ('Right Ring', 'O', 'L', 'Right Top'),
    '-G': ('Right Ring', 'L', 'G', 'Right Bot'),
    '-T': ('Right Pinky', 'P', 'T', 'Right Top'),
    '-S': ('Right Pinky', ';', 'S', 'Right Bot'),
    '-D': ('Right Pinky Ext', '[', 'D', 'Right Top Ext'),
    '-Z': ('Right Pinky Ext', "'", 'Z', 'Right Bot Ext'),
}

ORDER_LEFT = [('S', 'S-'), ('T', 'T-'), ('K', 'K-'), ('P', 'P-'), ('W', 'W-'), ('H', 'H-'), ('R', 'R-')]
ORDER_RIGHT = [('F', '-F'), ('R', '-R'), ('P', '-P'), ('B', '-B'), ('L', '-L'), ('G', '-G'), ('T', '-T'), ('S', '-S'), ('D', '-D'), ('Z', '-Z')]

def parse_stroke(s):
    keys = []
    has_hyphen = '-' in s
    parts = s.split('-') if has_hyphen else [s]
    left = parts[0]
    
    if any(c.isdigit() for c in left):
        keys.append('#')
        
    idx = 0
    for letter, key_name in ORDER_LEFT:
        if idx < len(left) and left[idx] == letter:
            keys.append(key_name)
            idx += 1
            
    if idx < len(left) and left[idx] == 'A':
        keys.append('A-'); idx += 1
    if idx < len(left) and left[idx] == 'O':
        keys.append('O-'); idx += 1
    if idx < len(left) and left[idx] == '*':
        keys.append('*'); idx += 1
    if idx < len(left) and left[idx] == 'E':
        keys.append('-E'); idx += 1
    if idx < len(left) and left[idx] == 'U':
        keys.append('-U'); idx += 1
        
    right = left[idx:] if not has_hyphen else parts[1]
    if '*' in right:
        keys.append('*')
        right = right.replace('*', '')
    ridx = 0
    for letter, key_name in ORDER_RIGHT:
        if ridx < len(right) and right[ridx] == letter:
            keys.append(key_name)
            ridx += 1
    return keys

def load_dictionaries():
    chord_to_word = {}
    word_to_chords = {}
    for p in DICTIONARY_PATHS:
        if os.path.isfile(p):
            try:
                with open(p, 'r', encoding='utf-8') as f:
                    d = json.load(f)
                    for chord, word in d.items():
                        chord_to_word[chord] = word
                        clean_word = word.lower().strip()
                        if clean_word not in word_to_chords:
                            word_to_chords[clean_word] = []
                        if chord not in word_to_chords[clean_word]:
                            word_to_chords[clean_word].append(chord)
            except Exception:
                pass
    return chord_to_word, word_to_chords

def render_ascii_keyboard(keys_set):
    def k(key, steno_char, qwerty_char):
        if key in keys_set:
            return f"\033[1;30;46m {qwerty_char} \033[0m"
        return f"\033[90m[{qwerty_char}]\033[0m"

    top = f"{k('S-', 'S', 'Q')} {k('T-', 'T', 'W')} {k('P-', 'P', 'E')} {k('H-', 'H', 'R')} {k('*', '*', 'T')}  |  {k('*', '*', 'Y')} {k('-F', 'F', 'U')} {k('-P', 'P', 'I')} {k('-L', 'L', 'O')} {k('-T', 'T', 'P')} {k('-D', 'D', '[')}"
    quote_char = "'"
    bot = f"{k('S-', 'S', 'A')} {k('K-', 'K', 'S')} {k('W-', 'W', 'D')} {k('R-', 'R', 'F')} {k('*', '*', 'G')}  |  {k('*', '*', 'H')} {k('-R', 'R', 'J')} {k('-B', 'B', 'K')} {k('-G', 'G', 'L')} {k('-S', 'S', ';')} {k('-Z', 'Z', quote_char)}"
    thm = f"             {k('A-', 'A', 'C')} {k('O-', 'O', 'V')}  |  {k('-E', 'E', 'N')} {k('-U', 'U', 'M')}       [Space: Commit]"
    
    return f"{top}\n{bot}\n{thm}"

def main():
    if len(sys.argv) < 2:
        print("Usage: steno-lookup.py <word or chord> [--json]")
        sys.exit(1)
        
    query = sys.argv[1].strip()
    as_json = "--json" in sys.argv
    
    chord_to_word, word_to_chords = load_dictionaries()
    
    # Check if query is a steno chord (uppercase with hyphen or steno letters)
    is_chord = bool(re.match(r'^[#A-Z0-9*+/-]+$', query) and any(c in query for c in "-*/" or len(query) > 1))
    
    results = []
    
    if query.upper() in chord_to_word:
        # Direct chord hit
        word = chord_to_word[query.upper()]
        results.append((query.upper(), word))
    elif query.lower() in word_to_chords:
        # Direct word hit
        chords = word_to_chords[query.lower()]
        # Sort chords: single stroke first, then shortest length
        chords.sort(key=lambda c: (c.count('/'), len(c)))
        for c in chords[:5]:
            results.append((c, query.lower()))
    else:
        # Substring / partial match
        matches = []
        for w, clist in word_to_chords.items():
            if query.lower() in w:
                for c in clist:
                    matches.append((c, w))
        matches.sort(key=lambda item: (len(item[1]), item[0].count('/'), len(item[0])))
        results = matches[:5]
        
    if as_json:
        out = []
        for chord, word in results:
            strokes = chord.split('/')
            key_seq = [parse_stroke(s) for s in strokes]
            out.append({
                "word": word,
                "chord": chord,
                "strokes": key_seq
            })
        print(json.dumps(out))
        return

    if not results:
        print(f"\033[91mNo steno translation found for:\033[0m '{query}'")
        sys.exit(0)
        
    print(f"\033[1;37mSteno Lookup for:\033[0m \033[1;33m{query}\033[0m\n")
    
    for idx, (chord, word) in enumerate(results, start=1):
        strokes = chord.split('/')
        all_keys = []
        for s in strokes:
            all_keys.extend(parse_stroke(s))
        keys_set = set(all_keys)
        
        qwerty_keys = [KEY_INFO[k][1] for k in all_keys if k in KEY_INFO]
        qwerty_str = " + ".join(qwerty_keys) + " -> [Space]"
        
        print(f"\033[1;32m{idx}. Word:\033[0m \033[1m{word}\033[0m")
        print(f"   \033[1;34mSteno Chord:\033[0m  {chord}")
        print(f"   \033[1;35mMac QWERTY:\033[0m   {qwerty_str}")
        print()
        print(render_ascii_keyboard(keys_set))
        print("-" * 55)

if __name__ == "__main__":
    main()
