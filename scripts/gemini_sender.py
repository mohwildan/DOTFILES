#!/usr/bin/env python3
"""
Fast & Intelligent Gemini Question Sender
Supports pure text questions, rich text, and automatic Image Card file attachments
across any Google Account (/u/3/, /u/1/, /u/2/, /u/0/, etc.).
"""

import os
import json
import base64
import subprocess
import sys

BASE_PROJECT_DIR = "/Users/mac/project/sibermu-lms-scraping"
LAST_COPIED_JSON = os.path.join(BASE_PROJECT_DIR, "cards", "last_copied.json")

def get_clipboard_text():
    try:
        from AppKit import NSPasteboard
        pb = NSPasteboard.generalPasteboard()
        txt = pb.stringForType_("public.utf8-plain-text")
        if txt:
            return txt
    except Exception:
        pass
    try:
        return subprocess.check_output(['pbpaste'], text=True)
    except Exception:
        return ""

def send_to_gemini():
    cards_to_attach = []
    q_nums = []
    has_images = False
    saved_text = ""
    
    if os.path.exists(LAST_COPIED_JSON):
        try:
            with open(LAST_COPIED_JSON, 'r', encoding='utf-8') as f:
                data = json.load(f)
            has_images = data.get('has_images', False)
            if has_images:
                comb_card = data.get('combined_card')
                if comb_card and os.path.exists(comb_card):
                    cards_to_attach.append(comb_card)
                elif data.get('cards'):
                    for c in data['cards']:
                        if os.path.exists(c):
                            cards_to_attach.append(c)
            q_nums = data.get('question_numbers', [])
            saved_text = data.get('text', '')
        except Exception as e:
            print(f"Notice reading last_copied.json: {e}")

    # Build image payload if images are present
    files_payload = []
    if has_images and cards_to_attach:
        for c_path in cards_to_attach:
            try:
                with open(c_path, 'rb') as f:
                    b64 = base64.b64encode(f.read()).decode('utf-8')
                files_payload.append({
                    'name': os.path.basename(c_path),
                    'b64': b64
                })
            except Exception:
                pass

    # Build prompt text
    if files_payload:
        nums_str = ", ".join(str(n) for n in q_nums) if q_nums else ""
        prompt_text = f"Mohon bantu selesaikan soal kuis #{nums_str} pada gambar terlampir secara lengkap langkah demi langkah dan berikan pilihan jawaban yang benar (a, b, c, atau d)." if nums_str else "Mohon bantu selesaikan soal kuis pada gambar terlampir secara lengkap langkah demi langkah dan berikan pilihan jawaban yang benar."
    else:
        # Pure text question(s)
        clipboard_text = (saved_text or get_clipboard_text()).strip()
        if not clipboard_text:
            print("❌ Tidak ada teks soal atau gambar di clipboard.")
            return
        prompt_text = f"Mohon bantu jawab soal-soal kuis berikut dengan tepat dan berikan pilihan jawaban yang benar beserta penjelasan ringkasnya:\n\n{clipboard_text}"

    # JS injection for Chrome (works on any account /u/0, /u/1, /u/2, /u/3, etc.)
    js_code = f"""
    (async function() {{
        const filesData = {json.dumps(files_payload)};
        const prompt = {json.dumps(prompt_text)};
        
        const ed = document.querySelector('.ql-editor') 
                || document.querySelector('rich-textarea div[contenteditable="true"]')
                || document.querySelector('[contenteditable="true"]');
        if (!ed) return 'Error: Gemini editor not found';
        
        ed.focus();
        
        if (filesData && filesData.length > 0) {{
            const dt = new DataTransfer();
            for (const f of filesData) {{
                const byteCharacters = atob(f.b64);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {{
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }}
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], {{type: 'image/png'}});
                const file = new File([blob], f.name, {{type: 'image/png'}});
                dt.items.add(file);
            }}
            
            const pasteEvent = new ClipboardEvent('paste', {{
                bubbles: true,
                cancelable: true,
                clipboardData: dt
            }});
            ed.dispatchEvent(pasteEvent);
            
            // Allow attachment to register in Angular state
            await new Promise(r => setTimeout(r, 200));
            
            const p = ed.querySelector('p') || ed;
            p.innerText = prompt;
            ed.dispatchEvent(new Event('input', {{ bubbles: true }}));
        }} else {{
            // Pure text question insertion
            const p = ed.querySelector('p') || ed;
            p.innerText = prompt;
            ed.dispatchEvent(new Event('input', {{ bubbles: true }}));
        }}
        
        // Check and auto-dismiss any first-time image disclaimer dialogs (Agree / Setuju)
        setTimeout(() => {{
            const agreeBtn = Array.from(document.querySelectorAll('button, .mat-mdc-button-base')).find(b => {{
                const t = (b.innerText || '').trim().toLowerCase();
                return t === 'agree' || t === 'setuju' || t === 'i agree';
            }});
            if (agreeBtn) {{
                agreeBtn.click();
            }}
        }}, 100);

        // Auto click Send Message after short delay
        setTimeout(() => {{
            const btn = document.querySelector('button[aria-label="Send message"]')
                     || document.querySelector('button[aria-label*="Send"]')
                     || document.querySelector('.send-button')
                     || document.querySelector('button:has(mat-icon[data-mat-icon-name="send"])')
                     || document.querySelector('.send-button-container button');
            if (btn && !btn.disabled) {{
                btn.click();
            }} else {{
                ed.dispatchEvent(new KeyboardEvent('keydown', {{ key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true }}));
            }}
        }}, 350);
        
        return 'SUCCESS';
    }})();
    """

    # Smart Tab Finder AppleScript: scores tabs to pick the active account (e.g. /u/3/)
    applescript = f"""
    tell application "Google Chrome"
        set found to false
        set targetW to 1
        set targetIdx to 1
        set maxScore to -1
        
        set w_idx to 0
        repeat with w in windows
            set w_idx to w_idx + 1
            set t_idx to 0
            repeat with t in tabs of w
                set t_idx to t_idx + 1
                set u to URL of t
                if u contains "gemini.google.com" then
                    set score to 10
                    -- Bonus if active tab in window
                    if (active tab index of w) is t_idx then set score to score + 20
                    -- Bonus if front window
                    if w_idx is 1 then set score to score + 10
                    -- Bonus if multi-account URL (/u/3/, /u/1/, /u/2/)
                    if u contains "/u/" then set score to score + 15
                    
                    if score > maxScore then
                        set maxScore to score
                        set targetW to w_idx
                        set targetIdx to t_idx
                        set found to true
                    end if
                end if
            end repeat
        end repeat
        
        if not found then
            if (count of windows) is 0 then make new window
            tell front window to make new tab with properties {{URL:"https://gemini.google.com/u/3/app"}}
            delay 1.5
            set targetW to 1
            set targetIdx to (active tab index of front window)
        end if
        
        set (active tab index of window targetW) to targetIdx
        set index of window targetW to 1
        activate
        
        execute active tab of window targetW javascript {json.dumps(js_code)}
    end tell
    """

    try:
        p = subprocess.Popen(['osascript'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = p.communicate(input=applescript, timeout=10)
        if stderr:
            print(f"Notice from AppleScript: {stderr}")
    except Exception as e:
        print(f"Error executing Gemini sender: {e}")

if __name__ == '__main__':
    send_to_gemini()
