type send_message =
  { message : string; attachments : string list; recipient : string }

type send_group_message =
  { message : string; attachments : string list; group_id : string }

type 'response t =
  | Send_message : send_message -> int64 t
  | Send_group_message : send_group_message -> int64 t

val call : OBus_proxy.t -> 'response t -> 'response Lwt.t
