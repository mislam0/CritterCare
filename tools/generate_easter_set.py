#!/usr/bin/env python3
"""Compatibility entry point: generate updated flat Easter sprites."""
from generate_flat_easter_brainrot import entries, write_png
if __name__=='__main__':
    for path, painter in entries[0:6]:
        write_png(path,painter)
    print('The Bananini Bow Tie is intentionally preserved unchanged.' if 'easter'=='brainrot' else 'Cracked Egg Head now replaces the original bunny-ear art.')
