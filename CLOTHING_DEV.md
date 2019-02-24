# Clothing Development Notes

This temporary document annotates all the tasks of the development stages to fix the current problems with library clothing. For a detailed description of the new clothing system, ans its differences from the original, see:

- [`CLOTHING_NEW.md`][CLOTHING_NEW]


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Introduction](#introduction)
    - [Sources Annotations](#sources-annotations)
    - [Keep Original Code](#keep-original-code)
- [Development Steps](#development-steps)
    - [Dedicated Tests](#dedicated-tests)
- [Tasks List](#tasks-list)
    - [Tests](#tests)
    - [Dispose of `worn` and `wearing`](#dispose-of-worn-and-wearing)
    - [Adapt Verbs](#adapt-verbs)
        - [`wear` and `remove`](#wear-and-remove)
        - [Inventory and Examine Actor](#inventory-and-examine-actor)
        - [Verbs Referencing `worn`](#verbs-referencing-worn)

<!-- /MarkdownTOC -->

-----

# Introduction

Some general guidelines on the development approach employed.

## Sources Annotations

To keep track of pending and done tasks, I'll add pattern-specific comments in all the places in the library sources (and tests files) that will be affected by the development of the new clothing system (but not small optimizations and other tweaks unrelated the clothing changes and fixes):

```
-- >>> dev-clothing: ADDED >>>
-- >>> dev-clothing: DELETED >>>
-- >>> dev-clothing: FIXME >>>
-- >>> dev-clothing: TODO >>>
-- >>> dev-clothing: TWEAKED >>>
```

These will allow to quickly find any (or all) code areas that related to the current changes, so that the whole development process is easy to track and review. Before merging into `master` branch, all these comments will be removed.

## Keep Original Code

Also, I'll be keeping a commented-out copy of the original code next to any tweaked/deleted code, in order to make it easier to track changes and potential problems/oversights. The following comments patterns will be used to mark original code blocks:

```
-- >>> original code >>>
-- <<< original code <<<
```

Again, these will be deleted before merging into `master` branch.


# Development Steps

The following list resumes the overall steps required to implement the new system.

- [ ] Dispose of the `worn` entity and the `wearing` set, and use instead just the `donned` boolean attribute (which shall ultimately be renamed to `worn`).
- [ ] Ensure that nested clothes are never considered as being worn.
- [ ] List separately carried and worn items by actors, for both Hero (via 'inventory') and NPCs (via 'examine actor').
- [ ] When the verbs `wear`/`remove` fail, report only the blocking items (instead of the full list of worn items).
- [ ] Remove hard-coded handling of special clothes like coats and skirts, and allow authors to implement those via some new (optional) clothing attributes: `blockslegs` and `twopieces`.
- [ ] Allow authors to free number clothing layers, instead of imposing exponential layering (2, 4, 8, 16, 32, 64).
- [ ] Add new clothing attribute `facecover` to allow handling goggles, beards, masks, etc., independently from `headcover`.
- [ ] Establish some rules on how the library should handle verbs that might interact with a worn clothing item (including implicit taking), then enforce them in the library vers, and provide clear guidelines for authors so that they might create custom verbs that comply to these guidelines and won't interfere with worn clothing.


The details of each step are covered in the Tasks Lists sections below.


## Dedicated Tests

All testing will be done against the (already existing) `tests/clothing/ega.alan` adventure file. Some tweaks to the EGA source will be required in order to allow testing the new clothing system, but that's fine for EGA will still be the reference test adventure for clothing after the new system will be in place. 

I'll add a separate subset of tests in the `tests/clothing/` folder, using the `DEV_*.*` pattern for all tests files. This will allow to run independent tests without altering the original tests, which are a useful reference for comparing the behavior of the tweaked code to that of the original codebase during development.

- [`tests/clothing/`][testsclothing]:
    + [`ega.alan`][ega.alan] — "Emporium Alani" adventure for clothing tests.
    + [`DEV.bat`][DEV.bat] — execute a subset of tests dedicated to development:
        * [`DEV_init.a3log`][DEV_init.a3log]/[`.a3sol`][DEV_init.a3sol] — test clothing initialization.

At a later stage, when the clothing code revision work is complete, I'll start to run the original tests too, to confirm that the original problems are solved. In some cases, this will require adpating the original commands scripts to the new system or the tweaks done to the EGA adventure in the meantime. Before merging into `master` branch, the separate tests can either be stripped of the `DEV_` prefix and preserved, or just deleted if redundant.


# Tasks List

Here are the various tasks list for shifting to the new clothing system, largely based on the same work done for the Italian version of the StdLib.

- [x] __SOURCE ANNOTATIONS__ — Mark all places in the library sources that need to be tweaked.
- [ ] __ADOPT BUILD 1870__ — A bug was recently found that prevented using `DIRECTLY IN` inside nested loops. It was fixed in [developer snapshot 1870], so the StdLib _must_ adopt the new build in this work.
    + [ ] Update Alan version references in all adventures sources.

[developer snapshot 1870]: https://www.alanif.se/download-alan-v3/development-snapshots/development-snapshots/build1870

## Tests

- [x] Create `tests/clothing/DEV.bat` script to run tests only with solution files with name pattern `DEV_*.a3sol`.
- [ ] Add tests to track tweaked clothing features.
- [ ] __EGA__ — Tweak `ega.alan` test adventure to reflect changes in the library code and/or provide better testing material:

## Dispose of `worn` and `wearing`

Before actually removing the `worn` entity and the `wearing` set from the library code, and use instead just the `donned` boolean attribute (which will be renamed to `worn`) any references to them (in VERBs, EVENTs, etc.) must be subsituted with the new system. This will require a gradual approach, starting with the `clothing` class initialization and the `wear` and `remove` verbs, and then dealing with the `i` (inventory) verb, and then adapting every other verb that references `worn` and `wearing`.

- [ ] __MOVE `donned` ON `thing`__ — The `donned` attribute must be made available on the `thing` class, not just on `clothing`, fro two reasons:
    1. Allow to carry out checks in syntaxes of verbs that might affect worn items.
    1. Enable authors to implement non-clothing wearables (eg. wearable `device`s like VR goggles).
- [ ] __CLOTHING INITIALIZATION__ — Tweak initialization of `clothing`:
    + [ ] Fix code referencing `worn` and `wearing`.


## Adapt Verbs

Many verbs need to be adapted to work with the new system, for various reasons. Some verbs will appear in multiple tasks lists in this section, because each list tracks a specific set of tweaks, which might be independent of other types of changes.


### `wear` and `remove`

Obviously, changes to the `wear` and `remove` verbs in `lib_classes.i` are central to the new clothings system, so we'll assign to them a task list of its own.

- [ ] `wear`
- [ ] `remove`


### Inventory and Examine Actor

When taking inventory or examining actors, the library should produce two separate lists for carried and worn items. Also, these verbs should produce a "not wearing anything" message for it adds verbosity and would be intrusive in adventures that don't employ clothing. When examining NPCs, the "empty handed" message should not be produced either, to reduce verbosity (it's implicit) and prevent complications in adventures that don't implement NPCs carrying possesions.

- [ ] `lib_verbs.i`:
    + [ ] `i` (inventory)
- [ ] `lib_classes.i`:
    + [ ] `examine` (on `actor`)


### Verbs Referencing `worn`

These general verbs must also be adapted for they contain references to the `worn` entity.

- [ ] `lib_verbs.i`:
    + [ ] `attack_with`
    + [ ] `attack`
    + [ ] `drop`
    + [ ] `i` (inventory)
    + [ ] `kick`
    + [ ] `shoot_with`
    + [ ] `shoot`
    + [ ] `take`
    + [ ] `wear`

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS                                
------------------------------------------------------------------------------>


[CLOTHING_NEW]: ./CLOTHING_NEW.md


<!-- tests files -->

[testsclothing]: ./tests/clothing/ "Navigate to folder"
[ega.alan]: ./tests/clothing/ega.alan "View source"
[DEV.bat]: ./tests/clothing/DEV.bat "View source"
[DEV_init.a3log]: ./tests/clothing/DEV_init.a3log "View source"
[DEV_init.a3sol]: ./tests/clothing/DEV_init.a3sol "View source"


<!-- EOF -->