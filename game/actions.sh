verb::look() {
  if [[ "$dobject" ]]; then
    if [[ "$iobject" ]]; then
      echo "You look at the $dobject with the $iobject"
    else
      echo "You look at the $dobject"
    fi
  else
    echo "$(get-attr "$location" long_description)"
  fi
}

verb::go() {
  local direction= destination=

  case "$dobject" in
    n|north) direction=north ;;
    e|east) direction=east ;;
    s|south) direction=south ;;
    w|west) direction=west ;;
  esac
  if [[ "$direction" == "" ]]; then
    echo "'$direction' isn't a place or direction I'm aware of. Try 'north', 'east', 'south', or 'west'."
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
