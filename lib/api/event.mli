type 'event t

type message_received =
  { timestamp : int64
  ; sender : string
  ; group_id : string
  ; message : string
  ; attachments : string list
  }

type receipt_received = { timestamp : int64; sender : string }

type sync_message_received =
  { timestamp : int64
  ; source : string
  ; destination : string
  ; group_id : string
  ; message : string
  ; attachments : string list
  }

val listen : OBus_proxy.t -> 'event t -> 'event Lwt_stream.t Lwt.t

val message_received : message_received t

val receipt_received : receipt_received t

val sync_message_received : sync_message_received t
