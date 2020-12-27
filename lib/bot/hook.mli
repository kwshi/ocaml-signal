
type 'msg t

val make : ('event -> 'msg) -> 'event Signal_api.Event.t -> 'msg t

val listen : OBus_proxy.t -> 'msg t list -> 'msg Lwt_stream.t Lwt.t
