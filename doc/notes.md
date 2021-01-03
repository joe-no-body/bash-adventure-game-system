Entities
--------

- globals   
    - current location
- verbs

### Objects


- definition
    - display name
    - action handler
    - flags
    - globals
    - initial contents
- game state
    - seen? - determines description verbosity
    - contents

```sh
object::lantern() {
    called: "brass lantern"
    location: living-room
    adjectives: brass
    synonyms: lamp lantern light
    flags: takeable light
    initial_description: "A battery-powered lantern is on the trophy case."
    subsequent_description: "There is a brass lantern (battery-powered) here."
    size: 15
}
```

### Locations

Locations are objects with additional properties:

- definition
    - exits

```sh
location::living-room() {
    called: "Living Room"
    east: kitchen
    west: strange-passage if cyclops-fled else "The wooden door is nailed shut."
    down: via trap-door-exit
    flags: land lit sacred
    visible: stairs
    contains: nails nails-pseudo
}
```

API
---

### Globals

- `$player_location`
- `$verb`
- `$direct_object`
- `$indirect_object`

### Main loop

- `parse` - parse input into globals
    - `$verb`, `$direct_object`, `$indirect_object`
- `perform VERB D-OBJ I-OBJ` - execute a command
- `say MSG` - print a message

### Game state

- `global` - declare a global variable that will be included in game state

#### Containment

- `move OBJ to DEST` - move OBJ into the object DEST
- `remove OBJ` - move object to the shadow realm (this makes it hidden and unreachable, but its state, etc. continues to exist if it's ever `move`d back into reality)
- `in? OBJ CONTAINER` - check if OBJ is located in CONTAINER
- `contents_of CONTAINER` - return contents
- `exits_from ROOM`

#### Flags

- `flag? OBJ FLAG` - check if flag is set
- `set_flag OBJ FLAG` - set flag
- `clear_flag OBJ FLAG` - clear flag

### Object Declaration

These functions are only useful when an object is being declared.

- `called:` - set object display name
- `location:` - set object location
- `adjectives:` - set adjectives that can be used to reference the object
- `synonyms:` - set names that can be used to reference the object
- `flags:` - set object flags
- `contains:` - set initial contents of an object
- `initial_description:` - set description to be displayed before an object has
  first been acted upon by the player
- `subsequent_description:` - set description to be displayed after an object
  has been acted upon by the player

#### Functions for rooms
- `north:`, `northeast:`, `east:`, `southeast:`, `south:`, `southwest:`,
  `west:`, `northwest:`, `up:`, `down:`, `in:`, `out` - exit declarations
- more traditional syntax: 
  `add_exit DIRECTION [-if FLAG [-else MSG]] [-handler FUNC]`
- `visible:` - set "local global" objects visible from a room


### Even more magical syntax

Could get fairly wild with this.

```sh
if the lantern is takable; then
    :
fi

if the lantern is lit; then
    :
fi

if the bag contains the cookies; then
    :
fi
```