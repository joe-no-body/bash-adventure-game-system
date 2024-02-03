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

Syntax entries can optionally accept a single direct object or a direct object
and indirect object using the keyword `OBJ`.

Commands can be parsed using the function `parse`. `parse` takes a
series of words as its arguments and attempts to match them to one of the
defined syntaxes. If it matches successfully, it updates the variables `verb`,
`dobject`, and `iobject`, which store the function that implements the verb, the
direct object of the command, and the indirect object of the command,
respectively. For example, given the syntax above, 
`parse attack the troll with the sword` would set `verb=verb::attack`, 
`dobject=troll`, and `iobject=sword`.

Sample usage of this parser can be found in `game/syntax.sh`
and in `test/parse.bats`.

There is partially-implemented support for optional articles -- currently, `the`
is ignored when it's found where an object is expected, so 
`attack the troll with the sword` is treated the same as 
`attack troll with sword`.

There is a game object management system partially implemented in `objects.bash`
that should eventually be integrated with the parser. Work to do this is
partially done in `nouns.bash` but not yet integrated with the main command
parser. The object management system aims to create discrete objects with unique
identifiers, so `the sword` would be resolved to an identifier like
`object::golden-sword` rather than just `sword`.

The ultimate aim of this integration would be to support noun phrases (ex. `the
living room`) and disambiguation of nouns using adjectives (ex. if the current
room has a single object called `the golden sword`, then you can refer to it as
just `sword`, but if it has two objects called `the golden sword` and 
`the silver sword` then you have to say `golden sword` to make it clear what you
mean).

### Features

* language parsing
* rooms

### Wishlist

* object management system
  * object parsing - support for objects with adjectives and articles
* interrupts
* saving and loading game state from files

### Dev requirements

* shellcheck
* bats
* npm

### Dependencies

A sufficiently modern version of bash, but nothing else. To maximize
compatibility, this program is implemented in pure Bash without using any
external programs like sed, grep, awk, etc.

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
