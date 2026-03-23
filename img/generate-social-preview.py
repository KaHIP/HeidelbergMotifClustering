#!/usr/bin/env python3
"""Generate the GitHub social preview image (1280x640) for HeidelbergMotifClustering.

Creates social-preview.svg and converts to social-preview.png via Inkscape.
"""
import os, subprocess
DIR = os.path.dirname(os.path.abspath(__file__))
SVG_PATH = os.path.join(DIR, "social-preview.svg")
PNG_PATH = os.path.join(DIR, "social-preview.png")
# SVG is maintained directly as social-preview.svg
subprocess.run([
    "inkscape", SVG_PATH,
    "--export-type=png",
    f"--export-filename={PNG_PATH}",
    "--export-width=1280",
    "--export-height=640",
], check=True, capture_output=True)
print(f"Saved {PNG_PATH}")
