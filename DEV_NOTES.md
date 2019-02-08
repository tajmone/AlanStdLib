# Development Notes

Some notes on the current work to attempt getting rid of `worn` to store Hero's worn clothes and rely only on the `wearing` set-attribute instead.


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Introduction](#introduction)
- [Development Plan and Status](#development-plan-and-status)
    - [How The New System Works](#how-the-new-system-works)
- [Overview of `worn`](#overview-of-worn)
- [Occurences of `worn` in The Library](#occurences-of-worn-in-the-library)
    - [Clothing Initialization](#clothing-initialization)
    - [Verbs `wear` and `remove`](#verbs-wear-and-remove)
    - [The `worn_clothing_check` Event](#the-worn_clothing_check-event)
    - [RunTime Messages](#runtime-messages)
    - [Generic Verbs Referring to `worn`](#generic-verbs-referring-to-worn)
        - [attack](#attack)
        - [attack_with](#attack_with)
        - [drop](#drop)
        - [inventory](#inventory)
        - [kick](#kick)
        - [shoot](#shoot)
        - [shoot_with](#shoot_with)
        - [take](#take)
        - [wear](#wear)

<!-- /MarkdownTOC -->

-----

# Introduction

After uncovering the various bugs and problems relating to the clothing `Event` and how moving clothing in and out of `worn` crosses paths with `Extract` checks, it might be worth trying to dispose of the `worn` altogether and attempt relying only on the `wearing` set instead.

This approach should also allow using shared code to handle items worn by both the Hero and NPCs.

# Development Plan and Status

Due to `worn` being referenced in many parts of the library code, a well planned multi-steps approach is required in order to avoid breaking the library.

- [x] Document [all occurences of `worn` in the StdLib code][occurences of worn].
- [ ] Disable handling Hero's worn items via `worn`:
    + [x] Tweak initialization of `clothing` class:
        * [x] Remove handling Hero differently.
        * [x] Remove any reference to `worn`.
        * [x] Iterate over all clothing items _directly in_ every actor, and if the item was marked as `donned` by the author then add it to the `wearing` set of the actor.
    + [x] Tweak [`worn_clothing_check` Event][worn event]:
        * [x] Remove handling Hero differently.
        * [x] Remove any reference to `worn`.
        * [x] Just ensure that any clothing _directly in_ an actor and `donned` is added to `wearing` set of the actor.
    + [ ] Tweak `wear` and `remove` verbs in `lib_classes.i`.
    + [ ] Tweak [RunTime messages] in `lib_messages.i`.
    + [ ] Tweak inventory/`i` verb.
- [ ] Fix all [verbs in `lib_verbs.i` referencing `worn`][worn verbs].
- [ ] Check that there are no leftover references to `worn` in the library.
- [ ] Delete definition of `worn` entity.

During the development stages the `worn` entity should be left in the library, to prevent compiler errors, until no more references to it are left in the library code.

The clothing tests already present in the test suite should provide enough feedback on the impact that these changes will have on the library behavior. It's better not to commit changed tests transcripts for keeping the original output provides a better comparison to the upstream code behaviour — at least not until the tweaks are deemed as stable and there is a need to fine tuning.

> __NOTE__ — I'll be adding a comment containing `devworn` to all the tweaked code, to make it easier to carry out search operations to spot the modified code sections before merging into master. I'll also be adding similar comments to any code that requires tweaking, as a reminder.
> 
> For now, I'll also be leaving a commented-out copy of the original code, enclosed in these comments:
> 
> ```
> -- >>> original code >>>
> ...
> -- <<< original code <<<
> ```

## How The New System Works

Because we don't have a separate `worn` container to store the Hero's worn items, authors will now define worn clothes in their adventures by placing them in the actor and marking them as `IS donned`. Example:

```alan
THE hero_shoes IsA cl_shoes IN hero
  IS donned.
```

The library will take care of all `donned` items during initialization of the `clothing` class, and ensure that they are also included in the `wearing` set of the actor.

# Overview of `worn`

The `worn` is a `entity` with container properties, defined in `lib_classes.i` (188):

```alan
THE worn ISA ENTITY
  CONTAINER TAKING CLOTHING.
    HEADER SAY hero_worn_header OF my_game.
    ELSE SAY hero_worn_else OF my_game.
END THE.
```


# Occurences of `worn` in The Library

I'll list here all the places of the library code which reference the `worn`, so that every occurence might be adjusted to work with the new system.

## Clothing Initialization

In `lib_classes.i` (220, 230), initialization of `clothing` ensure that:

- Items in Hero's worn are also added to his `wearing` set:

    ```alan
      INITIALIZE


        -- the set attribute 'IS wearing' is defined to work for both the hero
        -- and NPCs:

        IF THIS IN worn
          THEN INCLUDE THIS IN wearing OF hero.
        END IF.
    ```

- Items in Hero's `wearing` set are marked as `donned` and moved to `worn` (if they aren't already)

    ```alan

        FOR EACH ac ISA ACTOR
          DO
            IF ac = hero
              THEN
                IF THIS IN wearing OF hero AND THIS <> null_clothing
                  THEN
                    IF THIS NOT IN worn
                      THEN LOCATE THIS IN worn.
                    END IF.
                    MAKE THIS donned.
                END IF.
    ```

## Verbs `wear` and `remove`

Both the `wear` and `remove` verbs `lib_classes.i` (339, 476) rely heavily on clothing items being inside `worn` during their execution to make the necessary calculations on the currently worn items which might prevent the action (by blocking the various wearing layers).

## The `worn_clothing_check` Event

An every-turn event is defined in `lib_classes.i` (611) to ensure that clothing acquired by Hero in mid-game are correctly marked as `donned` and placed in `worn`

```alan
EVENT worn_clothing_check
  FOR EACH ac ISA ACTOR
    DO
      FOR EACH cl ISA CLOTHING, IN wearing OF ac
        DO
          IF ac = hero
            THEN
              IF cl NOT IN worn
                THEN LOCATE cl IN worn.
                  MAKE cl donned.
              END IF.
```

## RunTime Messages

In `lib_messages.i` (41, 55, 71) the `worn` is referenced to customize listings of worn items:

- `CONTAINS_COMMA` (41):

    ```alan
      CONTAINS_COMMA: "$01"
        IF parameter1 ISA CLOTHING
          THEN
            -- the following snippet adds "(being worn)" after all
            -- pieces of clothing worn by an NPC, at 'x [actor]'

            IF parameter1 IS donned
              THEN
                IF parameter1 NOT IN worn
                  THEN "(being worn)"
                END IF.
            END IF.
        END IF.
        "$$,"
    ```

- `CONTAINS_COMMA` (55):

    ```alan
          CONTAINS_AND: "$01"
        IF parameter1 ISA CLOTHING
          THEN
            -- the following snippet adds "(being worn)" after all
            -- pieces of clothing worn by an NPC, after 'x [actor]'

            IF parameter1 IS donned
              THEN
                IF parameter1 NOT IN worn
                  THEN "(being worn)"
                END IF.
            END IF.
        END IF.

        "and"
    ```

- `CONTAINS_END` (71):

    ```alan
      CONTAINS_END: "$01"
        IF parameter1 ISA CLOTHING
          THEN
            -- the following snippet adds "(being worn)" after all
            -- pieces of clothing worn by an NPC, after 'x [actor]'

            IF parameter1 IS donned
              THEN
                IF parameter1 NOT IN worn
                  THEN "(being worn)"
                END IF.
            END IF.
        END IF.
        "."
    ```

## Generic Verbs Referring to `worn`

Various verbs in `libs_verbs.i` also refer to `worn` and will have to be fixed accordingly:

- [ ] `attack` (481)
- [ ] `attack_with` (557)
- [ ] `drop` (1964)
- [ ] inventory/`i` (3385)
- [ ] `kick` (3550)
- [ ] `shoot` (6314)
- [ ] `shoot_with` (6393)
- [ ] `take` (7178)
- [ ] `wear` (8743)

### attack

- `attack` (481):

    ```alan
    ADD TO EVERY THING
      VERB attack
        CHECK my_game CAN attack
        ...
        AND target NOT IN worn
          ELSE SAY check_obj_not_in_worn2 OF my_game.
    ```

### attack_with

- `attack_with` (557):

    ```alan
    ADD TO EVERY THING
      VERB attack_with
        WHEN target
          CHECK my_game CAN attack_with
          ...
          AND target NOT IN worn
            ELSE SAY check_obj_not_in_worn2 OF my_game.

    ```

### drop

- `drop` (1964):

    ```alan
    ADD TO EVERY OBJECT
      VERB drop
        CHECK my_game CAN drop
          ELSE SAY restricted_response OF my_game.
        AND obj IN hero
          ELSE
            IF obj IN worn
              THEN SAY check_obj_not_in_worn3 OF my_game.
              ELSE SAY check_obj_in_hero OF my_game.
                END IF.
    ```

### inventory

- inventory/`i` (3385):

    ```alan
    VERB i
      CHECK my_game CAN i
        ELSE SAY restricted_response OF my_game.

      DOES
        LIST hero.

        IF COUNT DIRECTLY IN worn > 0   -- See the file 'classes.i', subclass 'clothing'.
          THEN LIST worn.     -- This code will list what the hero is wearing.
        END IF.
    ```

### kick

- `kick` (3550):

    ```alan
    ADD TO EVERY THING
      VERB kick
        CHECK my_game CAN kick
          ELSE SAY restricted_response OF my_game.
        ...
        AND target NOT IN worn
          ELSE SAY check_obj_not_in_worn2 OF my_game.
    ```

### shoot

- `shoot` (6314):

    ```alan
    ADD TO EVERY THING
        VERB shoot
        CHECK my_game CAN shoot
          ELSE SAY restricted_response OF my_game.
        ...
        AND target NOT IN worn
          ELSE SAY check_obj_not_in_worn2 OF my_game.
    ```

### shoot_with

- `shoot_with` (6393):

    ```alan
    ADD TO EVERY THING
      VERB shoot_with
        WHEN target
          CHECK my_game CAN shoot_with
            ELSE SAY restricted_response OF my_game.
          ...
          AND target NOT IN worn
            ELSE SAY check_obj_not_in_worn2 OF my_game.
    ```


### take

- `take` (7178):

    ```alan
        DOES
          IF obj ISA ACTOR
            THEN SAY THE obj. "would probably object to that."
          -- actors are not prohibited from being taken in the checks; this is to
          -- allow for example a dog to be picked up, or a bird to be taken out of
          -- a cage, etc.

          ELSIF obj ISA OBJECT
            THEN IF obj DIRECTLY IN worn
                THEN LOCATE obj IN hero.
                  "You take off" SAY THE obj. "and carry it in your hands."
                  IF obj ISA CLOTHING
                    THEN EXCLUDE obj FROM wearing OF hero.
                  END IF.
                ELSE LOCATE obj IN hero.
                  "Taken."
              END IF.
          END IF.
    ```

### wear

- `wear` (8743):

    ```alan
    ADD TO EVERY OBJECT
      VERB wear
        CHECK my_game CAN wear
          ELSE SAY restricted_response OF my_game.
        AND obj NOT IN worn
          ELSE SAY check_obj_not_in_worn1 OF my_game.
    ```



<!-----------------------------------------------------------------------------
                               REFERENCE LINKS                                
------------------------------------------------------------------------------>

<!-- internal xrefs -->

[occurences of worn]: #occurences-of-worn-in-the-library "Jump to document section"
[worn verbs]: #generic-verbs-referring-to-worn "Jump to document section"
[RunTime messages]: #runtime-messages "Jump to document section"
[worn event]: #the-worn_clothing_check-event "Jump to document section"



<!-- EOF -->