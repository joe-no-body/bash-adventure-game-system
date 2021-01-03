Objects
-------

Very DSL-like:

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

Another idea:

```sh
location::living-room() {
    display_name="Living Room"

    add_exit -to kitchen -dir east
    add_exit -to strange-passage -dir west -if cyclops-fled -else "The wooden door is nailed shut."
    add_exit -dir down -via trap-door-exit

    flags=(land lit sacred)
    visible=(stairs)
    contains=(nails nails-pseudo)
}
```


### Possible implementation

```sh

init_object() {
    local obj="$1"

    "$obj"   # call the object function
}

set_attr() {
    DATA["$obj/$1"]="$2"
}

called:() {
    set_attr display_name "$1"
}

east:() {
    add_exit east "$@"
}
```