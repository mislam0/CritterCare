#!/usr/bin/env python3
"""Register an existing PNG in the Shop without hand-editing GDScript.

Run from any folder: python tools/add_shop_item.py
Only Python's standard library is needed. Artwork is copied unchanged.
"""
import argparse
import json
from pathlib import Path
import re
import shutil
import struct
import sys

SLOTS = {"pet": {"head": (640, 640), "face": (640, 640), "neck": (640, 640)},
         "room": {"wall": (1200, 525), "decor": (410, 396), "rug": (640, 130)}}
THEMES = ("nature", "study", "smart_casual", "halloween", "christmas", "pixel_knight", "easter", "brainrot")


def register(root, image, title, category, slot, theme, price, description, item_id=None, dry_run=False):
    root, image = Path(root).resolve(), Path(image).expanduser().resolve()
    title, description = title.strip(), description.strip()
    if not title or len(title) > 48 or "\n" in title:
        raise ValueError("Use an item name of 1–48 characters on one line.")
    if category not in SLOTS or slot not in SLOTS[category]:
        raise ValueError("Pet slots: head, face, neck. Room slots: wall, decor, rug.")
    if theme not in THEMES:
        raise ValueError("Choose a theme: " + ", ".join(THEMES))
    if type(price) is not int or not 0 <= price <= 999999:
        raise ValueError("Price must be a whole number from 0 to 999999.")
    if not description or len(description) > 180:
        raise ValueError("Give a short description of 1–180 characters.")
    item_id = item_id or re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_")
    if not re.fullmatch(r"[a-z][a-z0-9_]{0,47}", item_id):
        raise ValueError("Use --id with a short ID such as sparkle_hat (letters, numbers, underscores).")
    if not image.is_file() or image.suffix.lower() != ".png":
        raise ValueError("Choose an existing .png image.")
    with image.open("rb") as file:
        header = file.read(24)
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        raise ValueError("The file is not a PNG with a readable image header.")
    size = struct.unpack(">II", header[16:24])
    if size != SLOTS[category][slot]:
        raise ValueError(f"{category}/{slot} needs a {SLOTS[category][slot][0]}×{SLOTS[category][slot][1]} canvas; this image is {size[0]}×{size[1]}. See docs/SHOP_IMAGES.md.")
    catalog = root / "data/shop.gd"
    original = catalog.read_text(encoding="utf-8")
    begin = original.index("const ITEMS = {")
    end = original.index("\n}\n", begin)
    if re.search(r'^\s*"' + re.escape(item_id) + r'"\s*:', original, re.M):
        raise ValueError(f"The ID {item_id!r} already exists. Choose a new ID; existing purchases use these IDs.")
    destination = root / "assets/shop" / category / slot / f"{item_id}.png"
    if destination.exists():
        raise ValueError(f"{destination.name} already exists; this tool never overwrites artwork.")
    relative = destination.relative_to(root).as_posix()
    info = dict(name=title, theme=theme, category=category, slot=slot, price=price, description=description)
    fields = json.dumps(info, ensure_ascii=False, separators=(", ", ":"))[:-1]
    entry = f'\t"{item_id}":{fields}, "texture":preload("res://{relative}")}}'
    before = original[:end].rstrip()
    updated = before + ("" if before.endswith(",") else ",") + "\n\n\t# Added with tools/add_shop_item.py\n" + entry + original[end:]
    result = {"id": item_id, "image": relative, "category": category, "slot": slot, "theme": theme, "price": price}
    if dry_run:
        return result
    destination.parent.mkdir(parents=True, exist_ok=True)
    backup = catalog.with_suffix(".gd.before_image_import")
    temporary = catalog.with_suffix(".gd.importing")
    if not backup.exists(): shutil.copyfile(catalog, backup)
    try:
        shutil.copyfile(image, destination)
        temporary.write_text(updated, encoding="utf-8")
        temporary.replace(catalog)
    except Exception:
        destination.unlink(missing_ok=True)
        temporary.unlink(missing_ok=True)
        raise
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image")
    parser.add_argument("--name")
    parser.add_argument("--category", choices=SLOTS)
    parser.add_argument("--slot")
    parser.add_argument("--theme", choices=THEMES)
    parser.add_argument("--price", type=int)
    parser.add_argument("--description")
    parser.add_argument("--id")
    parser.add_argument("--dry-run", action="store_true", help="Check the image and catalog without changing files")
    args = parser.parse_args()
    prompts = {"image":"PNG path", "name":"Item name", "category":"Category (pet/room)",
               "slot":"Slot (head/face/neck or wall/decor/rug)", "theme":"Theme (" + ", ".join(THEMES) + ")",
               "price":"Price in gold", "description":"Short description"}
    try:
        for field, prompt in prompts.items():
            if getattr(args, field) is None:
                if not sys.stdin.isatty(): parser.error("Missing --" + field)
                value = input(prompt + ": ").strip().strip('"')
                setattr(args, field, int(value) if field == "price" else value)
        result = register(Path(__file__).resolve().parents[1], args.image, args.name, args.category,
                          args.slot, args.theme, args.price, args.description, args.id, args.dry_run)
    except (OSError, ValueError) as error:
        parser.exit(1, f"Could not add item: {error}\n")
    print(("Ready to add (no files changed): " if args.dry_run else "Added: ") + json.dumps(result, ensure_ascii=False))
    if not args.dry_run:
        print("Open Godot and let it import the PNG, then press F5. Re-export the itch.io build to publish the same item there.")


if __name__ == "__main__":
    main()
