#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o noglob

# ensure namespace isn't polluted
\export PATH=''
\unalias -a
hash -r

# safer IFS, though it shouldn't matter if we're safe
IFS=$' \t\n'


location=west_of_house
verb=
direct_object=
indirect_object=

declare -A west_of_house=(
  [name]="West of House"
  [north]=north_of_house
  [south]=south_of_house
  [long_description]="You are standing in an open field west of a white house, with a boarded front door.
There is a small mailbox here."
  #[west]=forest-1
  # TODO:
  #[east]="sorry@The door is boarded and you can't remove the boards."
  #[sw]="stone-barrow if won-flag"
  #[in]="stone-barrow if won-flag"
  # action
  # flags
  # global
)

declare -A north_of_house=(
  [name]="North of House"
  [west]=west_of_house
  [east]=east_of_house
  [south]="sorry@It's all boarded up."
  [long_description]="You are standing in an open field west of a white house, with a boarded front door."
  [long_description]="You are facing the north side of a white house. There is no door here, and all the windows are boarded up. To the north a narrow path winds through the trees."
)

declare -A south_of_house=(
  [name]="South of House"
  [west]=west_of_house
  [east]=east_of_house
  [north]="sorry@It's all boarded up."
  [long_description]="You are facing the south side of a white house. There is no door here, and all the windows are boarded."
)

declare -A east_of_house=(
  [name]="East of House"
  [north]=north_of_house
  [south]=south_of_house
  [long_description]="You are behind the white house. A path leads into the forest to the east. In one corner of the house there is a small window which is slightly ajar."
)

declare -A flags=()

flag?() {
  local flagname
  case "$#" in
    1) flagname="$1" ;;
    2) flagname="$1/$2" ;;
    *) echo "fatal interal error: flag? requires 1 or 2 args but got $#"
       exit 1
       ;;
  esac
  [[ -v flags["$flagname"] ]] && [[ "${flags["$flagname"]}" != '' ]]
}

set_flag() {
  local flagname
  case "$#" in
    1) flagname="$1" ;;
    2) flagname="$1/$2" ;;
    *) echo "fatal interal error: flag? requires 1 or 2 args but got $#"
       exit 1
       ;;
  esac
  flags["$flagname"]=1
}

clear_flag() {
  local flagname
  case "$#" in
    1) flagname="$1" ;;
    2) flagname="$1/$2" ;;
    *) echo "fatal interal error: flag? requires 1 or 2 args but got $#"
       exit 1
       ;;
  esac
  flags["$flagname"]=
}

parse() {
  verb=
  direct_object=
  indirect_object=
  case "$*" in
    "go north"|n|north)
      verb=go direct_object=north
      ;;
    "go east"|e|east)
      verb=go direct_object=east
      ;;
    "go south"|s|south)
      verb=go direct_object=south
      ;;
    "go west"|w|west)
      verb=go direct_object=west
      ;;
    look)
      verb=look
      ;;
    *)
      echo "Sorry, I didn't quite understand that. Try again."
      return 1
      ;;
  esac
}

print_cmd() {
  echo "verb='$verb' direct_object='$direct_object' indirect_object='$indirect_object'"
}

action::go() {
  local direction="$1"
  local tentative_location
  if [[ -v here["$direction"] ]]; then
    tentative_location="${here["$direction"]}"
    # handle non-exits
    if [[ "$tentative_location" == 'sorry@'* ]]; then
      echo "${tentative_location#sorry@}"
      return
    fi
    location="$tentative_location"
  else
    echo "You can't go that way."
    return 1
  fi
}

action::look() {
  echo "${here['long_description']}"
}

perform() {
  local V="$1" D="$2" I="$3"
  case "$V" in
    go)
      action::go "$D"
      ;;
    look)
      action::look
      ;;
    *)
      echo "Looks like you've stumped me. I don't know how to perform the verb '$V'"
      return 1
      ;;
  esac
}

main() {
  while true; do
    local -n here="$location"

    echo "# ${here['name']}"
    if ! flag? "$location" visited; then
      echo "${here['long_description']}"
    fi
    echo
    set_flag "$location" visited

    read -rep "> " -a user_input
    parse "${user_input[@]}" || continue
    perform "$verb" "$direct_object" "$indirect_object" || continue
  done
}
main "$@"