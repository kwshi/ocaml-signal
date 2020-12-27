type 'response t =
  | Is_registered : bool t
  | Send_message :
      { message : string; attachments : string list; recipient : string }
      -> int64 t
  | Send_end_session_message : { recipients : string list } -> unit t
  | Send_group_message :
      { message : string; attachments : string list; group_id : string }
      -> int64 t
  | Get_contact_name : { number : string } -> string t
  | Set_contact_name : { number : string; name : string } -> unit t
  | Set_contact_blocked : { number : string; blocked : bool } -> unit t
  | Set_group_blocked : { group_id : string; blocked : bool } -> unit t
  | Get_group_ids : string list t
  | Get_group_name : { group_id : string } -> string t
  | Get_group_members : { group_id : string } -> string list t
  | Update_group :
      { group_id : string
      ; name : string
      ; members : string list
      ; avatar : string
      }
      -> string t

val call : OBus_proxy.t -> 'response t -> 'response Lwt.t
