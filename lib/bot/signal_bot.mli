type ('model, 'msg) t

val make :
     init:(unit -> 'model Lwt.t)
  -> hooks:'msg Hook.t list
  -> update:('msg -> 'model -> 'model Lwt.t)
  -> ('model, 'msg) t

val hook : ('event -> 'msg) -> 'event Signal_api.Event.t -> 'msg Hook.t

val run : OBus_proxy.t -> ('model, 'msg) t -> 'model Lwt.t
