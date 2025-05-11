# These globals are expected to be set by BAGS, but we initialize them here to
# make shellcheck be quiet.
dobject=
iobject=
raw_verb=

verb::look() {
  # "look"
  if [[ ! "$dobject" ]]; then
    get-attr "$location" long_description
    return
  fi

  # "look [at] OBJ"
  if [[ ! "$iobject" ]]; then
    echo "You look at the $dobject"
    return
  fi

  # "look [at] OBJ [with] OBJ"
  echo "You look at the $dobject with the $iobject"
}

verb::go() {
  local direction='' destination=''

  case "$raw_verb" in
    n|north) direction=north ;;
    e|east) direction=east ;;
    s|south) direction=south ;;
    w|west) direction=west ;;
  esac

  if [[ ! "$direction" ]]; then
    case "$dobject" in
      object::north) direction=north ;;
      object::east) direction=east ;;
      object::south) direction=south ;;
      object::west) direction=west ;;
    esac
  fi
  if [[ ! "$direction" ]]; then
    # TODO: get the human-readable name for the object
    echo "'$dobject' isn't a place or direction I'm aware of. Try 'north', 'east', 'south', or 'west'."
    return
  fi

  if ! has-attr? "$location" "$direction"; then
    echo "I'm afraid you can't go $direction from here."
    return
  fi

  destination="$(get-attr "$location" "$direction")"

  # If the destination has the prefix "sorry@", strip the prefix and print out
  # the string verbatim - the path is blocked off.
  case "$destination" in
    sorry@*)
      echo "${destination#sorry@}"
      return
      ;;
  esac

  location="$destination"
  get-attr "$location" name
  if ! flag? "$location" visited; then
    get-attr "$location" long_description
  fi
  set-flag "$location" visited
}

__do_fail() {
  return 1
}

verb::fatal() {
  echo "inducing a fatal error"
  __do_fail
}
