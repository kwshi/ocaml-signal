module Method = Method
module Event = Event

val connect : [< `Session | `System ] -> OBus_connection.t Lwt.t

val proxy : OBus_connection.t -> OBus_proxy.t
