open Lwt.Syntax

type ('model, 'msg) t =
  { init : unit -> 'model Lwt.t
  ; hooks : 'msg Hook.t list
  ; update : 'msg -> 'model -> 'model Lwt.t
  }

let make ~init ~hooks ~update = { init; update; hooks }

let hook = Hook.make

let run proxy { init; update; hooks } =
  let* init = init () and* hooks = Hook.listen proxy hooks in
  Lwt_stream.fold_s update hooks init
