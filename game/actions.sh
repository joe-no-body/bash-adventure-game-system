verb::look() {
  if [[ "$dobject" ]]; then
    if [[ "$iobject" ]]; then
      echo "You look at the $dobject with the $iobject"
    else
      echo "You look at the $dobject"
    fi
  else
    echo "$(location long_description)"
  fi
}

verb::go() {
  local direction= destination=
  case "$dobject" in
    n|north) direction=north ;;
    e|east) direction=east ;;
    s|south) direciton=south ;;
    w|west) direction=west ;;
  esac
  if [[ "$direction" == "" ]]; then
    echo "'$direction' isn't a place or direction I'm aware of. Try 'north', 'east', 'south', or 'west'."
    return
  fi
  if ! destination="$(location "$direction")"; then
    echo "I'm afraid you can't go $direction from here."
    return
  fi
  location="$destination"
  echo "$(location name)"
  if ! location visited; then
    echo "$(location long_description)"
  fi
  set_location visited 1
}
