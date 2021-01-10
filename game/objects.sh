location='room::west-of-house'


room::west-of-house() {
  set-attr name "West of House"
  set-attr long_description "You are standing in an open field west of a white house, with a boarded front door.
There is a small mailbox here."
  set-attr north room::north-of-house
  set-attr south room::south-of-house
  #[west]=forest-1
  # TODO:
  #[east]="sorry@The door is boarded and you can't remove the boards."
  #[sw]="stone-barrow if won-flag"
  #[in]="stone-barrow if won-flag"
  # action
  # flags
  # global
}

room::north-of-house() {
  set-attr name "North of House"
  set-attr west room::west-of-house
  set-attr east room::east-of-house
  set-attr south "sorry@It's all boarded up."
  set-attr long_description "You are facing the north side of a white house. There is no door here, and all the windows are boarded up. To the north a narrow path winds through the trees."
}

room::south-of-house() {
  set-attr name "South of House"
  set-attr north "sorry@It's all boarded up."
  set-attr west room::west-of-house
  set-attr east room::east-of-house
  set-attr long_description "You are facing the south side of a white house. There is no door here, and all the windows are boarded."
}

room::east-of-house() {
  set-attr name "East of House"
  set-attr north room::north-of-house
  set-attr south room::south-of-house
  set-attr long_description "You are behind the white house. A path leads into the forest to the east. In one corner of the house there is a small window which is slightly ajar."
}