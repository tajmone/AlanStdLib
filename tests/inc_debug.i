
--==============================================================================
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--------------------------------------------------------------------------------
--
--                    T H E   D E B U G G I N G   M O D U L E
--
--------------------------------------------------------------------------------
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--==============================================================================

-- This modules adds to adventures some extra verbs and functionalities which
-- are helpful to provide quick "debug" information about the state of various
-- library classes, as well as some special verbs to alter their state.


--==============================================================================
-- DEBUG CLOTHING VALUES
--==============================================================================
-- A helper verb to check the coverage values of individual clothing items.

SYNTAX dbg_clothes = dbg_clothes (obj)
  WHERE obj IsA clothing
    ELSE "This verb can only be used with clothing items."

ADD TO EVERY clothing
  VERB dbg_clothes
    DOES
      ---------------------------------------
      -- Show coverage values (non-zero only)
      ---------------------------------------
      "'$1' VALUES:"
      IF obj:headcover = 0 AND obj:facecover = 0 AND obj:topcover = 0
      AND obj:botcover = 0 AND obj:feetcover = 0 AND obj:handscover = 0
        THEN
          "(none)"
        ELSE
          IF obj:headcover > 0
            THEN "| headcover:" SAY obj:headcover.
          END IF.
          IF obj:facecover > 0
            THEN "| facecover:" SAY obj:facecover.
          END IF.
          IF obj:topcover > 0
            THEN "| topcover:" SAY obj:topcover.
          END IF.
          IF obj:botcover > 0
            THEN "| botcover:" SAY obj:botcover.
          END IF.
          IF obj:feetcover > 0
            THEN "| feetcover:" SAY obj:feetcover.
          END IF.
          IF obj:handscover > 0
            THEN "| handscover:" SAY obj:handscover.
          END IF.
          IF obj IS NOT blockslegs
            THEN "| NOT blockslegs"
          END IF.
          IF obj IS twopieces
            THEN "| IS twopieces"
          END IF.
          "|"
      END IF.
      ------------------------
      -- Show if donned or not
      ------------------------
      "$nDONNED:"
      IF obj:donned
        THEN "Yes"
        ELSE "No."
      END IF.
  END VERB dbg_clothes.
END ADD TO clothing.


--/// EOF ///--
