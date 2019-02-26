# Clothing Development Notes

This temporary document annotates all the tasks of the development stages to fix the current problems with library clothing. For a detailed description of the new clothing system, ans its differences from the original, see:

- [`CLOTHING_NEW.md`][CLOTHING_NEW]


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Introduction](#introduction)
    - [Sources Annotations](#sources-annotations)
    - [Keep Original Code](#keep-original-code)
    - [Dedicated Tests](#dedicated-tests)
- [Development Steps Overwiew](#development-steps-overwiew)
    - [New System Implementation](#new-system-implementation)
    - [Post-Implementation Fixes](#post-implementation-fixes)
    - [Pre-Merge Cleanup](#pre-merge-cleanup)
- [Tasks List](#tasks-list)
    - [Tests](#tests)
        - [Debug Module](#debug-module)
    - [Clothing Attributes](#clothing-attributes)
    - [Dispose of `worn` and `wearing`](#dispose-of-worn-and-wearing)
    - [Adapt Verbs](#adapt-verbs)
        - [New Verb Messages](#new-verb-messages)
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


## Dedicated Tests

All testing will be done against the (already existing) `tests/clothing/ega.alan` adventure file. Some tweaks to the EGA source will be required in order to allow testing the new clothing system, but that's fine for EGA will still be the reference test adventure for clothing after the new system will be in place. 

I'll add a separate subset of tests in the `tests/clothing/` folder, using the `DEV_*.*` pattern for all tests files. This will allow to run independent tests without altering the original tests, which are a useful reference for comparing the behavior of the tweaked code to that of the original codebase during development.

- [`tests/clothing/`][testsclothing]:
    + [`ega.alan`][ega.alan] — "Emporium Alani" adventure for clothing tests.
    + [`DEV.bat`][DEV.bat] — execute a subset of tests dedicated to development:
        * [`DEV_init.a3log`][DEV_init.a3log]/[`.a3sol`][DEV_init.a3sol] — test clothing initialization.
        * [`DEV_inventory.a3log`][DEV_inventory.a3log]/[`.a3sol`][DEV_inventory.a3sol] — test how `inventory` and `examine actor` are handling separate lists of carried and worn.
        * [`DEV_skirts.a3log`][DEV_skirts.a3log]/[`.a3sol`][DEV_skirts.a3sol] — test special clothes: skirts, coats, bikinis, etc.
        * [`DEV_wear_remove.a3log`][DEV_wear_remove.a3log]/[`.a3sol`][DEV_wear_remove.a3sol] — general purpose tests for `wear`/`remove`.

At a later stage, when the clothing code revision work is complete, I'll start to run the original tests too, to confirm that the original problems are solved. In some cases, this will require adpating the original commands scripts to the new system or the tweaks done to the EGA adventure in the meantime. Before merging into `master` branch, the separate tests can either be stripped of the `DEV_` prefix and preserved, or just deleted if redundant.


# Development Steps Overwiew

The following list resumes the overall steps required to implement the new system. The details of each step are covered in the Tasks Lists sections below.

## New System Implementation

- [ ] Dispose of the `worn` entity and the `wearing` set, and use instead just the `donned` boolean attribute (which shall ultimately be renamed to `worn`).
- [ ] Ensure that nested clothes are never considered as being worn.
- [ ] List separately carried and worn items by actors, for both Hero (via 'inventory') and NPCs (via 'examine actor').
- [x] When the verbs `wear`/`remove` fail, report only the blocking items (instead of the full list of worn items).
- [x] Remove hard-coded handling of special clothes like coats and skirts, and allow authors to implement those via some new (optional) clothing attributes: `blockslegs` and `twopiecess`.
- [x] Allow authors to free number clothing layers, instead of imposing exponential layering (2, 4, 8, 16, 32, 64).
- [x] Add new clothing attribute `facecover` to allow handling goggles, beards, masks, etc., independently from `headcover`.
- [ ] Establish some rules on how the library should handle verbs that might interact with a worn clothing item (including implicit taking), then enforce them in the library vers, and provide clear guidelines for authors so that they might create custom verbs that comply to these guidelines and won't interfere with worn clothing.

## Post-Implementation Fixes

After the new system is in place, the old code, tests and documents need to be adapated accordingly.

- [ ] __TESTS__ — Command scripts of the original tests will need to be tweaked to mirror the new changes, some tests might no longer be needed and can be deleted.
- [ ] __COMMENTED DOCUMENTATION__ — Comments in the library sources documenting need to be revised so they mirror the new system.
- [ ] __DOCUMENTS__ — READMEs and documentation files must also be revised to reflect library changes.

## Pre-Merge Cleanup

Once everything is ready to be merged into `master` branch, all commented dev annotations in the sources should be removed, and temporary documents and files too.

- [ ] Remove all the `-- >>> dev-clothing` comments and `-- >>> original code >>>` commented out code.

-------------------------------------------------------------------------------

# Tasks List

Here are the various tasks list for shifting to the new clothing system, largely based on the same work done for the Italian version of the StdLib.

- [x] __SOURCE ANNOTATIONS__ — Mark all places in the library sources that need to be tweaked.
- [x] __ADOPT BUILD 1875__ — A bug was recently found that prevented using `DIRECTLY IN` inside nested loops. It was fixed in [developer snapshot 1870], so the StdLib _must_ adopt the lastest build currently available in this work.
    + [x] Use [Alan 3.0 beta6 build 1875][developer snapshot 1875] to carry out tests.
    + [x] Update Alan version in READMEs.
    + [x] Update Alan version references in all adventures sources.


## Tests

- [x] Create `tests/clothing/DEV.bat` script to run tests only with solution files with name pattern `DEV_*.a3sol`.
- [ ] Add tests to track tweaked clothing features.
- [ ] __EGA__ — Tweak `ega.alan` test adventure to reflect changes in the library code and/or provide better testing material:
    + [x] __DBG VERB__ — Tweak it to work with the new clothing system and attributes (verb now moved to `tests/inc_debug.i`):
        * [x] `facecover`
        * [x] `blockslegs`
        * [x] `twopieces`
        * [x] Don't show `worn` and `wearing` info.
    + [x] __UNDRESS VERB__ — Tweak it to work with new system (no use of `worn` or `wearing`).
    + [x] __WORN CLOTHES__ — Adapt code relating to worn items:
        * [x] __HERO__: Locate item `IN hero` instead of `worn`.
        * [x] __ALL ACTORS__: Set item as `donned`.
    + [x] __FIX SPECIAL CLOTHES__ — Use new `blockslegs`, `twopieces` and `facecover` attributes in existing clothes:
        * [x] skirt (`NOT blockslegs`)
        * [x] dress (`NOT blockslegs`)
        * [x] balaclava (use `facecover` + `headcover`)
        * [x] sky goggles (use `facecover`)
    + [x] __NEW CLOTHES__ — Add more clothing items for testing:
        * [x] coat
        * [x] bikini
        * [x] shirts: black and red
        * [x] ski helmet
    + [ ] __REDEFINE LAYERS__ — redesign the clothing layers numbering, dropping the old exponential system based on the Clothing Table, and adopt a new arbitrary system based on the needs of EGA.

### Debug Module

Create a separate debugging module `tests/inc_debug.i` that can be used by all test adventures and move there the custom debug verbs from EGA (and other adventures):

- [x] Create `tests/inc_debug.i`:
    + [x] Move here `DBG` verb from EGA and rename it `DBG_CLOTHES`
        * [x] Change use of `DBG` verb into `DBG_CLOTHES` in all commands scripts
      inside `tests/clothing/` folder.
    + [ ] Add new debug verbs:
        * [x] `DBG_INV <ACTOR>` to list all objects carried/worn by an actor (via `LIST` command).
        * [x] `DBG_COMP <ACTOR>` — to show compliance status of actors.
        * [x] Verb `subjugate` to toggle actors compliance.
- [ ] Include the new debug module in all other test adventures:
    + [x] `tests/clothing/ega.alan`
    + [ ] `tests/house/house.alan`
    + [ ] ... more ...

## Clothing Attributes

Add new attributes on `clothing` class:

- [x] `IS blockslegs` — i.e. prevents wearing/removing legsware from layers below. Skirts and coats are `NOT blockslegs`, for they don't prevent wearing/removing underware or other legswear which doesn't form a single-piece clothing with the torso (eg. a teddy, which would be blocked).
- [x] `IS NOT twopieces` — used for skirts/coats-like checks, if the item being worn/removed `IS twopieces` (eg. a bikini) it will be allowable to do so. Useful when implementing a two-pieces item as a single clothing, eg. a bikin which is worn/removed in a single action.
- [x] `facecover` — to allow wearing masks, beards, goggles without using up `headcover`.


## Dispose of `worn` and `wearing`

Before actually removing the `worn` entity and the `wearing` set from the library code, and use instead just the `donned` boolean attribute (which will be renamed to `worn`) any references to them (in VERBs, EVENTs, etc.) must be subsituted with the new system. This will require a gradual approach, starting with the `clothing` class initialization and the `wear` and `remove` verbs, and then dealing with the `i` (inventory) verb, and then adapting every other verb that references `worn` and `wearing`.

- [x] __MOVE `donned` ON `thing`__ — The `donned` attribute must be made available on the `thing` class, not just on `clothing`, fro two reasons:
    1. Allow to carry out checks in syntaxes of verbs that might affect worn items.
    1. Enable authors to implement non-clothing wearables (eg. wearable `device`s like VR goggles).
- [ ] __CLOTHING INITIALIZATION__ — Tweak initialization of `clothing`:
    + [x] Comment out the code that iterates every ACTOR to see if the clothing instance is in its  `wearing` set in order to make it `donned` and, in case of the Hero, move it to `worn`. None of this is any longer necessary, for a clothing items only needs to be DIRECTLY IN an ACTOR and `IS donned` for it to be worn by the actor.
    + [x] Suppress scheduling the `worn_clothing_check` EVENT. That's no longer required.
- [ ] __EVENT `worn_clothing_check`__:
    + [x] Commented out the whole event for it's no longer strictly required.
    + [ ] Now that the loop bug was fixed in Alan, we could use the event to check that any clothing item `INDIRECTLY IN HERO` is set to `NOT donned`. Although this should never happen due to Library verbs (which will now handle carefully the `donned` attribute in _any_ transferred thing), chances are that authors-created verbs in an adventure might not be handling these subtle cases correctly, and this event might help them.
    
        > __NOTE__ — I haven't implement such checks in the Italian library, partly due to the bug, partly because I didn't see it as strictly necessary; still, all clothing tests passed without problems.


## Adapt Verbs

Many verbs need to be adapted to work with the new system, for various reasons. Some verbs will appear in multiple tasks lists in this section, because each list tracks a specific set of tweaks, which might be independent of other types of changes.

### New Verb Messages

The new system required the introduction of some new `my_game` string attributes for verb responses.

|            attribute            |             string            |
|---------------------------------|-------------------------------|
| `check_obj1_not_worn_by_NPC_sg` | `"Currently $+1 is worn by"`  |
| `check_obj1_not_worn_by_NPC_pl` | `"Currently $+1 are worn by"` |


### `wear` and `remove`

Obviously, changes to the `wear` and `remove` verbs in `lib_classes.i` are central to the new clothings system, so we'll assign to them a task list of its own.

- [ ] __TEMP ATTRIBUTES__ — add new attributes on `definition_block`, for internal usage:
    + [x] `temp_cnt` (integer), used for listing carried/worn items.
    + [x] `temp_clothes { clothing }` used to track clothes preventing wear/remove actions.
    + [ ] Delete `ACTOR:wear_flag` (no longer needed).
    + [ ] Delete `ACTOR:tempcovered` (no longer needed).
- [x] __VERB `wear`__:
    + [x] __NON EXPONENTIAL LAYERS__ — Allow free arbitrary assignment of layers values.
    + [x] __FACE COVER VALUE__ — introduce checks for `facecover`.
    + [x] __SKIRT & COATS__ — no longer hardcoded layers, use `blockslegs` and `twopiece` instead.
    + [x] __FAILURE REPORT__ — list only blocking items.
- [x] __VERB `remove`__:
    + [x] __NON EXPONENTIAL LAYERS__ — Allow free arbitrary assignment of layers values.
    + [x] __FACE COVER VALUE__ — introduce checks for `facecover`.
    + [x] __SKIRT & COATS__ — no longer hardcoded layers, use `blockslegs` and `twopiece` instead.
    + [x] __FAILURE REPORT__ — list only blocking items.


### Inventory and Examine Actor

When taking inventory or examining actors, the library should produce two separate lists for carried and worn items. Also, these verbs should produce a "not wearing anything" message for it adds verbosity and would be intrusive in adventures that don't employ clothing. When examining NPCs, the "empty handed" message should not be produced either, to reduce verbosity (it's implicit) and prevent complications in adventures that don't implement NPCs carrying possesions.

- [x] `lib_verbs.i`:
    + [x] `i` (inventory)
        * [x] Produce separate lists of carried/worn via custom loops.
        * [x] Don't report that Hero is not wearing anything.
- [x] `lib_classes.i`:
    + [x] `examine` (on `actor`)
        * [x] Produce separate lists of carried/worn via custom loops.
        * [x] Don't report that actor is empty handed.
        * [x] Don't report that actor is not wearing anything.

The various library-defined runtime MESSAGES must also be tweaked now that the `worn` entity will be removed:

- [ ] `lib_messages.i` — fix references to `worn` entity:
    + [ ] `CONTAINS_COMMA`
    + [ ] `CONTAINS_AND`
    + [ ] `CONTAINS_END`


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
[DEV_skirts.a3log]: ./tests/clothing/DEV_skirts.a3log "View source"
[DEV_skirts.a3sol]: ./tests/clothing/DEV_skirts.a3sol "View source"
[DEV_wear_remove.a3log]: ./tests/clothing/DEV_wear_remove.a3log "View source"
[DEV_wear_remove.a3sol]: ./tests/clothing/DEV_wear_remove.a3sol "View source"
[DEV_inventory.a3log]: ./tests/clothing/DEV_inventory.a3log "View source"
[DEV_inventory.a3sol]: ./tests/clothing/DEV_inventory.a3sol "View source"

<!-- Alan Builds -->

[developer snapshot 1870]: https://www.alanif.se/download-alan-v3/development-snapshots/development-snapshots/build1870
[developer snapshot 1875]: https://www.alanif.se/download-alan-v3/development-snapshots/development-snapshots/build1875

<!-- EOF -->