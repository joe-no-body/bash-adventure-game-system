# Design and Implementation Notes

BAGS is an interactive fiction/text adventure game engine implemented in pure Bash and inspired by Infocom's Zork Implementation Language.

## Inspiration

Heavily inspired by the blog [Internal Secrets of Infocom Games](https://ifsecrets.blogspot.com/2019/02/chapter-1-zil-zilch-zap-and-zip.html) and the ZIL manuals.

## Systems

- object + rooms system
- command parsing
  - nouns
  - syntaxes
  - verbs
  - actions

---

- `syntax` builds `syntax_tree`
- `parse` uses `syntax_tree` to parse a command and sets `verb`, `dobject`, and `iobject` based on the result
- `perform` executes the action. Since `verb` contains the name of a function, it simply invokes `verb` with the values of `dobject` and `iobject` as arguments (although in `actions.sh` we use the `dobject` and `iobject` variables directly since thy're in scope)


## Code components

### `game/`

- `actions.sh` defines action functions corresponding to verbs
- `objects.sh` defines the objects that exist, which correspond to nouns
  - see `objects.bash` for the object system's implementation
- `syntax.sh` defines valid syntax entries

### `lib/`

- `bags.bash` contains initialization code and the main loop.
- `nouns.bash` defines a noun parsing system, which handles noun phrases like `living room` and `the red pen`
- `objects.bash` implements a DSL for initializing objects, including rooms. Objects must be declared with functions with names that begin `object::` or `room::`. Objects have attributes, flags, a location, and contents.
- `parse.bash` handles parsing commands and defines the `syntax` command for defining syntax entries.
- `perform.bash` handles executing commands by dispatching to the appropriate action function.

## Parsing

### Goals

- ease of implementation - wanted a DSL for defining commands instead of having to write a parser by hand
- overlapping commands - differentiate between `look`, `look at OBJ`, and `look at OBJ with OBJ`
- easy synonym support - we should be able to define `look at OBJ with OBJ` and `look at OBJ using OBJ` as equivalent without having to do anything too complex
- error reporting - if the player enters an invalid command, we should be able to tell them what part of the command was invalid

### Basics

Command syntaxes are defined using the `syntax` function and parsed using the `parse` function, both of which are implemented in `parse.bash`.

`syntax` is used as follows:

```sh
# a command with no object
syntax look = verb::look

# a command with a direct object
syntax look OBJ = verb::look

# commands with prepositions
syntax look in OBJ = verb::look-inside
syntax look at OBJ = verb::look

# commands with both a direct and indirect object and prepositions
syntax look at OBJ with OBJ = verb::look-with
syntax look at OBJ using OBJ = verb::look-with
```

Each syntax entry defines a command, which may optionally accept a direct object and indirect object. These commands correspond to an action function that, by convention, should have a name starting with `verb::`. Multiple commands can share the same action function.

`parse` accepts a command string and attempts to parse out a valid command or report an error if parsing fails. `parse` sets the shared variables `verb`, `dobject`, and `iobject` to the action function specified by the syntax, the direct object of the command, and the indirect object of the command, as applicable.

For example, given the syntaxes defined above, if we execute `parse look at castle using telescope`, we will have `verb=verb::look-with`, `dobject=castle`, and `iobject=telescope`.

### Building `syntax_tree`

Under the hood, `syntax` updates an associative array named `syntax_tree`, which is used by `parse` to check the grammar of commands, to identify direct and indirect objects named in those commands, and to identify which action function should be called to handle the command.

`syntax_tree` contains two kinds of entries: prefixes and full commands. A prefix entry has a blank value, while a full command has the name of an action function as its value. 

When `syntax` inserts an entry into `syntax_tree`, it breaks the command up into words and inserts an entry for each valid prefix, followed by an entry for the full command, which defines the action function to invoke. For example, the syntax entry for `look at OBJ with OBJ` above would result in the following entries:

```
[look]=
[look at]=
[look at OBJ]=
[look at OBJ with]=
[look at OBJ with OBJ]=verb::look-with
```

Importantly, a single entry can represent both a prefix and a full command. For example, if we have the following three syntax entries

```sh
syntax look OBJ = verb::look
syntax look at OBJ = verb::look
syntax look at OBJ with OBJ = verb::look-with
```

then we'll end up with the following syntax tree

```
[look]=verb:look
[look at]=
[look at OBJ]=verb::look
[look at OBJ with]=
[look at OBJ with OBJ]=verb::look-with
```

### Parsing with `syntax_tree`

`parse` is invoked with the player's entered command, with each word being passed as a separate argument.

To parse this command, `parse` iterates one word at a time and builds up a command prefix, which it attempts to match to a prefix in `syntax_tree`. If no matching prefix is found, then it will report an error.

One key advantage of matching prefixes like this is that we can identify the exact location of a syntax error. For example, given the above `syntax_tree`, attempting to parse `look at castle by telescope` will produce the error `I can't make sense of 'by' at the end of 'look at castle by'`.
