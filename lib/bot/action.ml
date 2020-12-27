type 'msg t = OBus_proxy.t -> 'msg Lwt.t

let make f m proxy = Signal_api.Method.call proxy m |> Lwt.map f

let run proxy action = action proxy
