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

  case "$dobject" in
    object::north) direction=north ;;
    object::east) direction=east ;;
    object::south) direction=south ;;
    object::west) direction=west ;;
  esac
  if [[ "$direction" == "" ]]; then
    # TODO: get the human-readable name for the object
    echo "'$dobject' isn't a place or direction I'm aware of. Try 'north', 'east', 'south', or 'west'."
    return
  fi

  if ! has-attr? "$location" "$direction"; then
    echo "I'm afraid you can't go $direction from here."
    return
  fi

  destination="$(get-attr "$location" "$direction")"

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
