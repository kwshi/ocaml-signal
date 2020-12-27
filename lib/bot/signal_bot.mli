module Method : sig
  include module type of Signal_api.Method

  type never

  val call : OBus_proxy.t -> never t -> never Lwt.t
end

module Event : sig
  include module type of Signal_api.Event

  type never

  val listen : OBus_proxy.t -> never t -> never Lwt_stream.t Lwt.t
end

type ('model, 'msg) t

val make :
     init:(unit -> 'model Lwt.t * 'msg option Action.t option)
  -> hooks:'msg Hook.t list
  -> update:('msg -> 'model -> 'model Lwt.t * 'msg option Action.t option)
  -> ('model, 'msg) t

val hook : ('event -> 'msg) -> 'event Event.t -> 'msg Hook.t

val action : ('response -> 'msg) -> 'response Method.t -> 'msg Action.t

val run : OBus_proxy.t -> ('model, 'msg) t -> 'model Lwt.t
