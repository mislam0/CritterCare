# Validation — v1.6.5

This consolidated release uses Godot 4.7.2 and the Compatibility renderer.
The current game and artwork are retained; release metadata and documentation
are consolidated under v1.6.5.

## Release checks

- Core gameplay integration: 420 checks, zero failures, with isolated test saves.
- Rendered shop regression: 351 checks, zero failures across all ten themes.
- Eight static shop, guide, fit, artwork, placement, and wording validators pass.
- All 60 purchase IDs, prices, themes, and slots remain compatible. Main shop
  artwork, room accents, and base furniture match the latest approved art.
- A fresh browser export is built from this source. Package checks verify ZIP
  integrity, root-level index.html, engine/game files, nine license files, and
  identical embedded and separate browser ZIPs.

Run `tests/verify.gd` with `--test-mode` for core checks and
`tests/verify_shop_art.gd` with `--test-mode` on a real renderer for shop checks.
See the README for the other feature suites and browser export command.

## Practical limits

Release checks run on Windows with isolated test saves. A local browser load
does not establish persistence, audio timing, fullscreen, or mobile behavior
on an itch.io page. Use [ITCH_IO.md](ITCH_IO.md) to check the intended host.
Native and browser saves remain separate. Name filtering runs offline and
cannot guarantee every future bypass; see [NAME_FILTER.md](NAME_FILTER.md).
