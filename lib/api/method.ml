type _ t =
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

let call (type response) proxy : response t -> response Lwt.t =
  let module Cl = Signal_dbus.Client in
  function
  | Is_registered -> Cl.is_registered proxy
  | Send_message { message; attachments; recipient } ->
      Cl.send_message proxy message attachments recipient
  | Send_end_session_message { recipients } ->
      Cl.send_end_session_message proxy recipients
  | Send_group_message { message; attachments; group_id } ->
      Cl.send_group_message proxy message attachments group_id
  | Get_contact_name { number } -> Cl.get_contact_name proxy number
  | Set_contact_name { number; name } -> Cl.set_contact_name proxy number name
  | Set_contact_blocked { number; blocked } ->
      Cl.set_contact_blocked proxy number blocked
  | Set_group_blocked { group_id; blocked } ->
      Cl.set_group_blocked proxy group_id blocked
  | Get_group_ids -> Cl.get_group_ids proxy
  | Get_group_name { group_id } -> Cl.get_group_name proxy group_id
  | Get_group_members { group_id } -> Cl.get_group_members proxy group_id
  | Update_group { group_id; name; members; avatar } ->
      Cl.update_group proxy group_id name members avatar
