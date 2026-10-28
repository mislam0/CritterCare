#!/usr/bin/env python3
"""Regenerate the v1.6.8 Brainrot assets using code, not image generation."""
from generate_brainrot_168 import ENTRIES, save_png
if __name__=='__main__':
    for path, painter in ENTRIES:
        save_png(path, painter)
    print('Generated propeller hat, 67 glasses, Tung Tung tie/poster, and 67 rug. Wallpaper retained.')
