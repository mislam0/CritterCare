#!/usr/bin/env python3
"""Check Room sets terminology without changing saved item IDs/prices."""
from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1]
shop = (root/'data/shop.gd').read_text()
main = (root/'scripts/main.gd').read_text()
tutorial = (root/'scripts/tutorial.gd').read_text()
errors=[]
if '"Room sets"' not in main: errors.append('Room sets tab missing')
if '"Pet accessories"' not in main: errors.append('Pet accessories tab missing')
if 'Room sets include Wallpaper, Decor Set, and Rug' not in tutorial: errors.append('Tutorial category explanation missing')
if 'item_is_room' not in main or 'Room makeover!' not in main: errors.append('Room-specific equip feedback missing')
if 'config/version="1.6.5"' not in (root/'project.godot').read_text(): errors.append('Expected consolidated release version 1.6.5')
ids = re.findall(r'^\s*"([^"\n]+)":\{"name":"([^"\n]+)", "theme":"([^"\n]+)", "category":"(?:pet|room)"',shop,re.M)
if len(ids) != 60: errors.append(f'Expected 60 items, got {len(ids)}')
if shop.count('"category":"room", "slot":"decor"') != 10: errors.append('Expected 10 Decor Sets')
if 'decor_room.decor_pieces.size() == 8' not in (root/'tests/verify.gd').read_text(): errors.append('Outdated decor anchor integration check')
if errors:
 print('Shop wording validation FAILED:')
 for e in errors: print('-',e)
 sys.exit(1)
print('Shop wording validation passed: 10 Decor Sets, 60 shop items, room-specific UI copy, 8-anchor regression updated.')
