BAGS: Bash Adventure Game System
================================

An adventure game engine written in Bash, inspired by the classic Infocom ZIL
system.

### Dev requirements

* shellcheck
* bats

### Probable features

* language parsing
* rooms
* objects
* interrupts
* saving and loading game state from files

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
