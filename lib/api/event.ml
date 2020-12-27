open Lwt.Syntax

type 'event t = OBus_proxy.t -> 'event Lwt_stream.t Lwt.t

type message_received =
  { timestamp : int64
  ; sender : string
  ; group_id : string
  ; message : string
  ; attachments : string list
  }

type receipt_received =
  { timestamp : int64
  ; sender : string
  }

type sync_message_received =
  { timestamp : int64
  ; source : string
  ; destination : string
  ; group_id : string
  ; message : string
  ; attachments : string list
  }

let listen proxy event = event proxy

let ( let< ) signal convert proxy =
  let+ events = signal proxy |> OBus_signal.connect in
  Lwt_react.E.to_stream events |> Lwt_stream.map convert

let message_received =
  let< timestamp, sender, group_id, message, attachments =
    Signal_dbus.Client.message_received
  in
  { timestamp; sender; group_id; message; attachments }

let receipt_received =
  let< timestamp, sender = Signal_dbus.Client.receipt_received in
  { timestamp; sender }

let sync_message_received =
  let< timestamp, source, destination, group_id, message, attachments =
    Signal_dbus.Client.sync_message_received
  in
  { timestamp; source; destination; group_id; message; attachments }
