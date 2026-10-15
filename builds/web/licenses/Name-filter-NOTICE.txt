# Name-filter data notices

CritterCare's offline name filter combines the following data. These licenses
apply to the supplied data and derived lexicon; they do not replace the project's
license for its original game code and art. Sources were retrieved 2026-10-15.

## LDNOOBW word lists

List of Dirty, Naughty, Obscene, and Otherwise Bad Words.
© 2012–2020 Shutterstock, Inc. and contributors.
Licensed under Creative Commons Attribution 4.0 International (CC-BY-4.0).

Source: https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
Pinned revision: 5faf2ba42d7b1c0977169ec3611df25a3c08eb13
License: https://creativecommons.org/licenses/by/4.0/
Full text: LDNOOBW-CC-BY-4.0.txt in this directory.

CritterCare includes the 28 language lists. Changes: normalization, deduplication,
selected neutral-term exclusions, additional terms, whole-name exceptions, and
derived lookup tables. The original lists are retained in the editable project.
No endorsement by the original authors is implied.

## better_profanity word list

Source: https://github.com/snguyenthanh/better_profanity
Pinned revision: b80ace7eb78addbdf7f625068e8a86f582d918c9
The project's word list supplements the English coverage. No Python package or
third-party filtering code runs in the game. The bundled MIT notice is copied
unchanged from that revision: better-profanity-MIT.txt.

## Unicode data

Unicode confusables data, version 18.0.0 (2026-08-06).
© 2026 Unicode, Inc.
Source: https://www.unicode.org/Public/security/latest/confusables.txt
Specification: https://www.unicode.org/reports/tr39/
License: Unicode-LICENSE.txt in this directory.

CritterCare generates selected case/compatibility/diacritic and look-alike folds
using the retained data and Python's Unicode database. This is a custom
name-matching scheme, not a claim of complete UTS #39 conformance. The generated
manifest records input hashes and the Python Unicode database version.

The Web ZIP includes copies of these notices in licenses/.
