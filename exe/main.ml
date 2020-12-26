[@@@ocaml.warning "-33"]

open Containers
open Lwt.Syntax
open Lwt.Infix
open Fun.Infix

let main =
  let* conn = OBus_bus.session () in
  let proxy =
    OBus_proxy.make
      ~peer:(OBus_peer.make ~connection:conn ~name:"org.asamk.Signal")
      ~path:[ "org"; "asamk"; "Signal" ]
  in
  let* stream_incoming = Message.stream_incoming proxy
  and* stream_sync = Message.stream_sync proxy in
  Lwt_stream.choose [ stream_incoming; stream_sync ]
  |> Lwt_stream.iter_p @@ handle proxy

let init_logs () =
  let make_ppf like =
    let buf = Buffer.create 512 in
    let flush () =
      let s = Buffer.contents buf in
      Buffer.reset buf
      ; s
    in
    (Fmt.with_buffer ~like buf, flush)
  in
  let ppf_app, flush_app = make_ppf Fmt.stdout in
  let ppf_dst, flush_dst = make_ppf Fmt.stderr in
  let reporter = Logs_fmt.reporter ~app:ppf_app ~dst:ppf_dst () in
  let report src lvl ~over cont msgf =
    let ch, flush =
      match lvl with
      | Logs.App -> (Lwt_io.stdout, flush_app)
      | _ -> (Lwt_io.stderr, flush_dst)
    in
    let cont' () =
      let write () = Lwt_io.write ch (flush ()) in
      let unblock = over %> Lwt.return in
      Lwt.finalize write unblock |> Lwt.ignore_result
      ; cont ()
    in
    reporter.report src lvl ~over:ignore cont' msgf
  in
  { Logs.report } |> Logs.set_reporter
  ; Logs.set_level (Some Info)

let () =
  init_logs ()
  ; Lwt_main.run main
