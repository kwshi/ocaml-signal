open Containers
open Fun.Infix
open Lwt.Infix

type origin = Sync | Incoming

type t =
  { timestamp : int64
  ; conversation : Conversation.t
  ; origin : origin
  ; sender : string
  ; body : string
  ; attachments : string list
  }

let of_incoming (timestamp, sender, group, body, attachments) =
  { timestamp
  ; sender
  ; conversation =
      (if String.is_empty group then Individual sender else Group group)
  ; origin = Incoming
  ; body
  ; attachments
  }

let of_sync (timestamp, sender, dest, group, body, attachments) =
  { timestamp
  ; sender
  ; conversation =
      (if String.is_empty group then Individual dest else Group group)
  ; origin = Sync
  ; body
  ; attachments
  }

let make_stream f s proxy =
  OBus_signal.connect @@ s proxy >|= Lwt_react.E.(map f %> to_stream)

let stream_sync = make_stream of_sync Signal_dbus.Client.sync_message_received

let stream_incoming =
  make_stream of_incoming Signal_dbus.Client.message_received
