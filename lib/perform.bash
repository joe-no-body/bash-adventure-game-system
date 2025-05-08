# perform executes the action handler function for the parsed verb, direct
# object, and indirect object. The main utility of this function is to provide a
# scope for the `verb`, `dobject`, and `iobject` locals so they'll be cleaned up
# after the function terminates.
perform() {
  local verb="$1" dobject="$2" iobject="$3"
  func? "$verb" || {
    echo "internal error: the action handler $verb does not exist" >&2
    return
  }
  "$verb" "$dobject" "$iobject"
}

print_cmd() {
  echo verb="$verb"
  echo dobject="$dobject"
  echo iobject="$iobject"
}