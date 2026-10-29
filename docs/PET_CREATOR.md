# Pets, saved looks, and Ball Play — v1.7.1

## Choose your friend

Pip the hamster is still the default. On the first name screen, choose
**Hamster · Choose pet + look** to open the creator before starting the tutorial.
Choose **Hamster, Kitten, Bunny, Puppy, Fox, or Panda**. Keep the name Pip or use
the existing name field. The friendly-name filter still applies.

Returning players can open **Style pet** from the room, Settings, or Shop.
Changing species or appearance is free and keeps the same story, name, needs,
money, lessons, purchases, and game records. There is one active pet in a story;
species choice does not create extra independent pets.

## Customize

- **Eyes, nose, mouth, ears, and fur pattern:** each pet has its own choices.
- **Six color areas:** main fur, markings, belly/muzzle, inner ears/paws, eyes,
  and nose. Tap a swatch to pick a color, or choose a ready-made palette.
- **Surprise me:** tries random features and a coordinated palette for the
  selected species.
- **Reset this look:** restores that species' default features and colors.
  This is separate from Reset progress.
- **Outfit preview:** temporarily hides accessories so you can see the face.
  It does not remove those accessories when you apply the look.

The large preview updates as you edit. Species thumbnails help you choose.
The creator remembers your designs for other species when you apply changes.
**Use this look** saves all creator changes. **Cancel**, Close, or Escape
discards them, including edits to saved looks. An unfinished name entry is
retained when you return from the creator.

Your selected species and features appear in the room, Picnic Catch, Logic Lab,
and Snack Jam. Existing Shop PNG accessories use the same face/body anchors for
every species; hats may cover part of an ear just as an outfit normally would.

## Quality of life: three saved looks

Open **Saved looks** in the creator. Each slot keeps a pet design and the pet
accessories currently equipped. Use **Save**, then **Use this look** to keep the
slot. An occupied slot asks for a second Save click before replacement.

**Wear** loads a slot into the preview; **Use this look** applies it. A slot
saved without accessories removes pet accessories when worn. Room decorations
are independent. Only owned items in their correct slots can be restored.
**Clear** empties a look slot; it is also a draft until you apply it.

These are appearance presets, separate from the three full-story save slots.
Autosaves and full-story slots include species designs, appearance presets,
and Ball Play return counts. Older version-9 saves remain loadable and start
with the classic hamster. Reset progress clears the new appearance/play data
and offers the first-play pet choice again; explicit story slots remain until
deleted, as before.

## Fun feature: Ball Play

Choose **Ball Play** in the room. Tap an open spot on the room floor or press
**Space** to throw. Your friend chases the ball and brings it back. Wait for
the return, then throw again. Every completed return adds **2 happiness**, up
to 100. There is no time limit, failure penalty, gold cost, or coin reward.

**Put toy away**, Escape, or opening a menu ends the activity. An unfinished
throw earns nothing. Leaving the game window pauses play; choose **Resume
ball** or press Space to continue. Gentler movement also reduces the ball arc
and removes its little settling bounce. Teaching waits while you play. After
a return, putting the toy away introduces input/output and IF/THEN in the
selected Game level's wording. The complete lesson goes into Knowledge and
uses the normal 60-second teaching cooldown.

Shortcuts while in the room: **C** opens Style pet, **B** toggles Ball Play,
**Space** throws/resumes while playing, and **Escape** puts the toy away.
Mouse and touch use the game's existing mouse-from-touch handling.

## Team editing map

| Change | File |
| --- | --- |
| Species choices, feature lists, default colors, palettes | `data/pet_looks.gd` |
| Animated pet shapes, eyes, mouths, ears, patterns, tails | `scripts/hamster.gd` |
| Creator layout and draft/saved-look controls | `scripts/pet_creator.gd` |
| Home/name-screen entry points and play rewards | `scripts/main.gd` |
| Ball movement, throw/return states, pause behavior | `scripts/ball_play.gd` |
| Ball texture and editable source artwork | `assets/toys/ball.png`, `ball.svg` |
| Appearance persistence and migrations | `scripts/save_data.gd`, `save_slots.gd` |
| Ball lesson and quiz | `data/lessons.gd` (`ball_play`) |
| Beginner wording and College detail | `data/lesson_language.gd` (`ball_play`) |
| Acceptance checks | `tests/verify_pets.gd` |

Pet bodies retain the original procedural animation system so features move
with dragging, petting, eating, and dancing. Room/Shop/activity artwork remains
PNG-based. No third-party pet artwork or additional runtime service is needed.
Always rebuild the browser export after changing the shared source.
