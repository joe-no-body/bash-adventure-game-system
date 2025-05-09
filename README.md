BAGS: Bash Adventure Game System
================================

An proof-of-concept adventure game engine written in pure Bash, inspired by the
classic Infocom ZIL system. This is nowhere near complete and not recommended
for... well, anything. However, it has some neat code that was fun to write.

In particular, `lib/parse.bash` features a natural language command parser and
DSL roughly inspired by the [syntax entries from ZIL](https://ifsecrets.blogspot.com/2019/02/chapter-3-syntax-entries-biggest.html). 

Defining commands with the DSL looks like this:

```sh
syntax look = verb::look
syntax look OBJ = verb::look
syntax look in OBJ = verb::look-inside
syntax look at OBJ = verb::look

syntax attack OBJ with OBJ = verb::attack

nouns::define object::troll -t the -a angry -s troll
nouns::define object::sword -t the -s sword

verb::look() {
  : # TODO: implement looking
}

verb::attack() {
  : # TODO: implement attacking
}
```

A syntax entry consists of the syntax definition, an equals sign, and the name
of a function to call if the player enters a command matching the given syntax.

For example, the syntax entry `syntax look = verb::look` means that we should
execute the function `verb::look` when the player enters the command `look`.

Syntax entries can optionally accept up to two objects (the direct and indirect
object, in that order) using the keyword `OBJ`. These direct and indirect
objects should be nouns defined using the function `nouns::define`. Nouns may
have an article and adjective, which can optionally be used to refer to them.
For example, given the nouns defined above, the player may refer to the troll as
`troll`, `the troll`, `angry troll`, or `the angry troll` in their commands, all
of which will be resolved to `object::troll` during parsing.

Commands are parsed using the function `parse`. `parse` takes a series of words
as its arguments and attempts to match them to one of the defined syntaxes. If
it matches successfully, it updates the variables `verb`, `dobject`, and
`iobject`, which can then be used by the `verb::attack` function. For example,
given the syntax and noun definitions above, calling 
`parse attack the troll with the sword` would set `verb=verb::attack`, 
`dobject=object::troll`, and `iobject=object::sword`.

Sample usage of this parser can be found in `game/syntax.sh` and in
`test/parse.bats`.

There is a game object management system partially implemented in `objects.bash`
that should eventually be integrated with the parser. Work to do this is
partially done in `nouns.bash` and has now been integrated with the main command
parser. The ultimate aim of this integration is to support noun phrases (ex.
`the living room`) and disambiguation of nouns using adjectives (ex. if the
current room has a single object called `the golden sword`, then you can refer
to it as just `sword`, but if it has two objects called `the golden sword` and
`the silver sword` then you have to say `golden sword` to make it clear what you
mean).

### Features

* natural language parsing
* rooms

### Wishlist

* object management system
  * object parsing - support for objects with adjectives and articles
* interrupts
* saving and loading game state from files
* NPCs

### Dev requirements

* shellcheck
* bats
* npm

### Dependencies

To play the game, only a sufficiently modern version of Bash is required. For
maximum compatibility, no external programs like sed, grep, awk, etc. are used.

For testing, [bats](https://github.com/bats-core/bats-core) and a couple support
packages are required. They can be installed using `npm`.

### Repo structure

* `doc/`: documentation and notes
* `lib/`: core library source
* `scratch/`: experimental code and sketches
* `test/`: bats tests

### Install

Run `npm install` to get required dependencies for testing.

### Testing

Run `make` to lint and test.

Run `bash game/main.sh` to play the (extremely rudimentary) demo game.
