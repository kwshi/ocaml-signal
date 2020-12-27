type 'msg t

val make : ('response -> 'msg) -> 'response Signal_api.Method.t -> 'msg t

val run : OBus_proxy.t -> 'msg t -> 'msg Lwt.t
