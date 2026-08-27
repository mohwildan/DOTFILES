#!/usr/bin/env python3
import re
import os
import subprocess

config_path = "/Users/mac/.aerospace.toml"

if not os.path.exists(config_path):
    print(f"Error: {config_path} not found")
    exit(1)

with open(config_path, "r") as f:
    content = f.read()

# Define the pattern for the active rule
active_pattern = r"(?m)^\[\[on-window-detected\]\]\nif\.app-id\s*=\s*'com\.google\.Chrome'\nrun\s*=\s*'layout floating'"

# Define the pattern for the commented-out rule
commented_pattern = r"(?m)^#\[\[on-window-detected\]\]\n#if\.app-id\s*=\s*'com\.google\.Chrome'\n#run\s*=\s*'layout floating'"

if re.search(active_pattern, content):
    # Rule is active, let's comment it out
    new_content = re.sub(
        active_pattern,
        "#[[on-window-detected]]\n#if.app-id = 'com.google.Chrome'\n#run = 'layout floating'",
        content
    )
    msg = "Chrome will now open in TILING mode"
    state = "Tiling"
elif re.search(commented_pattern, content):
    # Rule is commented, let's activate it
    new_content = re.sub(
        commented_pattern,
        "[[on-window-detected]]\nif.app-id = 'com.google.Chrome'\nrun = 'layout floating'",
        content
    )
    msg = "Chrome will now open in FLOATING mode"
    state = "Floating"
else:
    # Fallback in case formatting is slightly different (e.g. spaces/quotes)
    # Search for Chrome app-id rule and try to replace it cleanly
    alt_active_pattern = r"(\[\[on-window-detected\]\]\nif\.app-id\s*=\s*'com\.google\.Chrome'\nrun\s*=\s*'layout[^']*')"
    alt_commented_pattern = r"(#\[\[on-window-detected\]\]\n#if\.app-id\s*=\s*'com\.google\.Chrome'\n#run\s*=\s*'layout[^']*')"
    
    if re.search(alt_active_pattern, content):
        new_content = re.sub(
            alt_active_pattern,
            lambda m: "\n".join("#" + line for line in m.group(1).split("\n")),
            content
        )
        msg = "Chrome will now open in TILING mode"
    elif re.search(alt_commented_pattern, content):
        new_content = re.sub(
            alt_commented_pattern,
            lambda m: "\n".join(line.lstrip("#") for line in m.group(1).split("\n")),
            content
        )
        msg = "Chrome will now open in FLOATING mode"
    else:
        new_content = content
        msg = "Could not find Google Chrome float rule in config"

if new_content != content:
    with open(config_path, "w") as f:
        f.write(new_content)
    
    # Reload config
    subprocess.run(["/opt/homebrew/bin/aerospace", "reload-config"])
    # Show notification
    subprocess.run(["osascript", "-e", f'display notification "{msg}" with title "AeroSpace"'])
    print(f"Success: Toggled Chrome float state to {state if 'state' in locals() else 'changed'}")
else:
    # If no matching pattern was replaced, notify the user
    subprocess.run(["osascript", "-e", f'display notification "Error: Could not toggle Chrome rule format in ~/.aerospace.toml" with title "AeroSpace"'])
    print("Error: No changes made to the configuration file.")
