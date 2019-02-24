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
- [Tasks List](#tasks-list)

<!-- /MarkdownTOC -->

-----

# Introduction

Some general guidelines on the development approach employed.

## Sources Annotations

To keep track of the pending and done tasks, I'll add pattern-specific comments in all the places in the library sources (and tests files) that will be affected by this work of adaptation:

```
-- >>> dev-clothing: ADDED >>>
-- >>> dev-clothing: DELETED >>>
-- >>> dev-clothing: FIXME >>>
-- >>> dev-clothing: TODO >>>
-- >>> dev-clothing: TWEAKED >>>
```

These will allow to quickly find any (or all) code areas that related to the current changes, so that the whole development process is easy to track and review. Before merging into `master` branch, all these comments will be removed.

## Keep Original Code

Also, I'll be keeping a commented-out copy of the original code next to any tweaked/deleted code, in order to make it easier to track changes and potential problems/oversights. Again, these will be deleted before merging into `master` branch.

## Dedicated Tests

All testing will be done against the (already existing) `tests/clothing/ega.alan` adventure file. Some tweaks to the EGA source will be required in order to allow testing the new clothing system, but that's fine for EGA will still be the reference test adventure for clothing after the new system will be in place. 

I'll add a separate subset of tests in the `tests/clothing/` folder, using the `DEV_*.*` pattern for all tests files. This will allow to run independent tests without altering the original tests, which are a useful reference for comparing the behavior of the tweaked code to that of the original codebase during development.

At a later stage, when the clothing code revision work is complete, I'll start to run the original tests too, to confirm that the original problems are solved. In some cases, this will require adpating the original commands scripts to the new system or the tweaks done to the EGA adventure in the meantime. Before merging into `master` branch, the separate tests can either be stripped of the `DEV_` prefix and preserved, or just deleted if redundant.

# Tasks List

Here are the various tasks list for shifting to the new clothing system, largely based on the same work done for the Italian version of the StdLib.

- [ ] __SOURCE ANNOTATIONS__ — Mark all places in the library sources that need to be tweaked.
- [ ] __TESTS__:
    + [ ] Create `tests/clothing/DEV.bat` script to run tests only with solution files with name pattern `DEV_*.a3sol`.
    + [ ] Add tests to track tweaked clothing features.
    + [ ] __EGA__ — Tweak `ega.alan` test adventure to reflect changes in the library code and/or provide better testing material:


<!-----------------------------------------------------------------------------
                               REFERENCE LINKS                                
------------------------------------------------------------------------------>

[CLOTHING_NEW]: ./CLOTHING_NEW.md

<!-- EOF -->