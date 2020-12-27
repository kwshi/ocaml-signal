open Containers
open Fun.Infix

module type S = sig
  type event

  type msg

  val signal : event Signal_api.Event.t

  val from : event -> msg
end

type 'msg t = (module S with type msg = 'msg)

let make (type event msg) (f : event -> msg) s : msg t =
  let module Hook = struct
    type nonrec event = event

    type nonrec msg = msg

    let from = f

    let signal = s
  end in
  (module Hook)

let listen (type msg) proxy =
  Lwt_list.map_p (fun (module Hook : S with type msg = msg) ->
      Signal_api.Event.listen proxy Hook.signal
      |> Lwt.map @@ Lwt_stream.map Hook.from)
  %> Lwt.map Lwt_stream.choose
