type t = Individual of string | Group of string

let send proxy conv s =
  let send, dest =
    match conv with
    | Individual uid -> (Signal_dbus.Client.send_message, uid)
    | Group id -> (Signal_dbus.Client.send_group_message, id)
  in
  send proxy s [] dest
