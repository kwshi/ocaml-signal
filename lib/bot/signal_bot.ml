open Lwt.Syntax

module Method = struct
  include Signal_api.Method

  type never
end

module Event = struct
  include Signal_api.Event

  type never
end

type ('model, 'msg) t =
  { init : unit -> 'model Lwt.t * 'msg option Action.t option
  ; hooks : 'msg Hook.t list
  ; update : 'msg -> 'model -> 'model Lwt.t * 'msg option Action.t option
  }

let make ~init ~hooks ~update = { init; update; hooks }

let hook = Hook.make

let action = Action.make

let run proxy { init; update; hooks } =
  let action_msgs, action_push = Lwt_stream.create () in
  let maybe_run = function
    | None -> Lwt.return ()
    | Some action -> (
        let+ msg = Action.run proxy action in
        match msg with
        | None -> ()
        | Some msg -> action_push (Some msg)
      )
  in
  let init_model, init_action = init () in
  let* init_model = init_model and* hook_msgs = Hook.listen proxy hooks in
  let+ model_final =
    Lwt_stream.fold_s
      (fun msg model ->
        let model, action = update msg model in
        let+ model = model and+ () = maybe_run action in
        model)
      (Lwt_stream.choose [ hook_msgs; action_msgs ])
      init_model
  and+ () = maybe_run init_action in
  model_final
