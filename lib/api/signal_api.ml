module Method = Method
module Event = Event

let connect bus =
  ( match bus with
  | `Session -> OBus_bus.session
  | `System -> OBus_bus.system )
    ()

let proxy conn =
  OBus_proxy.make
    ~peer:(OBus_peer.make ~connection:conn ~name:"org.asamk.Signal")
    ~path:[ "org"; "asamk"; "Signal" ]
