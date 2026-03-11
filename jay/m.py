#!/usr/bin/env python3
import json
import re
import sys

RGB_RE = re.compile(r"rgb\((\d+), (\d+), (\d+)\)")

def rgb_to_hex(rgb: str) -> str:
    m = RGB_RE.match(rgb)
    if not m:
        raise ValueError(f"Invalid rgb value: {rgb}")
    r, g, b = map(int, m.groups())
    return f"#{r:02x}{g:02x}{b:02x}"

def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1], "r") as f:
            data = json.load(f)
    else:
        data = json.load(sys.stdin)

    c = data["colors"]

    theme = f"""[theme]
bar-bg-color = "{rgb_to_hex(c['background']['dark'])}"
bar-status-text-color = "{rgb_to_hex(c['on_background']['dark'])}"
border-color = "{rgb_to_hex(c['background']['dark'])}"
captured-focused-title-bg-color = "{rgb_to_hex(c['primary']['dark'])}"
captured-unfocused-title-bg-color = "{rgb_to_hex(c['background']['dark'])}"
focused-inactive-title-bg-color = "{rgb_to_hex(c['background']['dark'])}"
focused-inactive-title-text-color = "{rgb_to_hex(c['on_background']['dark'])}"
focused-title-bg-color = "{rgb_to_hex(c['primary']['dark'])}"
focused-title-text-color = "{rgb_to_hex(c['on_primary']['dark'])}"
separator-color = "{rgb_to_hex(c['background']['dark'])}"
unfocused-title-bg-color = "{rgb_to_hex(c['background']['dark'])}"
unfocused-title-text-color = "{rgb_to_hex(c['on_background']['dark'])}"

border-width = 2
font = "cozette 11"
"""

    print(theme)

if __name__ == "__main__":
    main()

