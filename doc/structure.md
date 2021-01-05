Core Systems
------------

- state (lib/state.sh)
    - `$GAMESTATE` - global state store. not for direct access by game code
    - `save-state FILE`
    - `load-state FILE`
    - `bind PREFIX ...CMD` - bind keys with the given prefix as local nameref
      variables, then call CMD
    - `bind-global NAME KEY` - create a global nameref variable for the named
      var
- objects (lib/objects.sh) - locations and things
    - `init-object NAME FUNC` - initialize object using FUNC
    - `init-location NAME FUNC`
    - `init-all` - find all functions named `object::*` and `location::*` and
      initialize objects from them
- game (lib/game.sh) - gamer shit
    - location
        - `in?`
        - `move`
    - flags
        - `flag?`
        - `set-flag`
        - `clear-flag`
- parsing (lib/parse.sh)
    - syntax trees and syntax definition
        - `$syntax_tree` - base action syntax tree
        - `$noun_phrases` - noun phrase parsing
        - `syntax ...WORDS = VERB`
        - `verb-synonyms VERB = ...SYNONYMS`
        - `adjective-synonyms ADJ = ...SYNONYMS`
        - `preposition-synonyms PREP = ...SYNONYMS`
    - command parsing
        - command vars
            - `$action` - name of the action handler for the given syntax
            - `$direct_object` - internal name of the direct object
            - `$indirect_object` - internal name of the indirect object
        - `parse ...WORDS` - parse the command and update the command vars
- performance (lib/perform.sh)
    - `$location_id` - the name of the location object
    - `$actor_handler` - name of the action handler for the player
    - `perform ACTION DIRECT-OBJECT INDIRECT-OBJECT` - invoke 


- arrays (lib/arrays.sh) - array management utilities
    - `ashift ARRNAME` - like `shift` but for the named array
    - `ashift ARRNAME to VAR` - like `ashift` but the shifted value is stored in VAR



- types (lib/types.sh) - meta-object/type system
    - ~don't exactly need this all the way. could do a more manual
      implementation
    - `define-type PREFIX FUNC` - define a type
    - `init-instance TYPE FUNC` - initialize an object of the given type with
      the given function and populate its initial values into GAMESTATE
    - `type::object`
    - `type::location`