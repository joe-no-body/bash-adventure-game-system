verb::look() {
  if [[ "$dobject" ]]; then
    if [[ "$iobject" ]]; then
      echo "You look at the $dobject with the $iobject"
    else
      echo "You look at the $dobject"
    fi
  else
    echo "You look around"
  fi
}