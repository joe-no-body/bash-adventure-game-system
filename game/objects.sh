location='west_of_house'

declare -A location__west_of_house=(
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

declare -A location__north_of_house=(
  [name]="North of House"
  [west]=west_of_house
  [east]=east_of_house
  [south]="sorry@It's all boarded up."
  [long_description]="You are standing in an open field west of a white house, with a boarded front door."
  [long_description]="You are facing the north side of a white house. There is no door here, and all the windows are boarded up. To the north a narrow path winds through the trees."
)

declare -A location__south_of_house=(
  [name]="South of House"
  [west]=west_of_house
  [east]=east_of_house
  [north]="sorry@It's all boarded up."
  [long_description]="You are facing the south side of a white house. There is no door here, and all the windows are boarded."
)

declare -A location__east_of_house=(
  [name]="East of House"
  [north]=north_of_house
  [south]=south_of_house
  [long_description]="You are behind the white house. A path leads into the forest to the east. In one corner of the house there is a small window which is slightly ajar."
)

location() {
  local -n locref="location__$location"
  local attr="$1"
  [[ -v locref["$attr"] ]] && echo "${locref["$attr"]}"
}

set_location() {
  local -n locref="location__$location"
  local attr="$1"
  local val="$2"
  locref["$attr"]="$val"
}