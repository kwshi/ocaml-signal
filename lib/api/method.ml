type send_message =
  { message : string; attachments : string list; recipient : string }

type send_group_message =
  { message : string; attachments : string list; group_id : string }

type _ t =
  | Send_message : send_message -> int64 t
  | Send_group_message : send_group_message -> int64 t

let call (type response) proxy : response t -> response Lwt.t = function
  | Send_message { message; attachments; recipient } ->
      Signal_dbus.Client.send_message proxy message attachments recipient
  | Send_group_message { message; attachments; group_id } ->
      Signal_dbus.Client.send_group_message proxy message attachments group_id
