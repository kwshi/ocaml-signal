[@@@ocaml.warning "-33"]

open Containers
open Lwt.Syntax
open Lwt.Infix
open Fun.Infix

type command = Ping | Calc of float

let is_digit = function
  | '0' .. '9' -> true
  | _ -> false

let spaces = Angstrom.take_while (Char.equal ' ')

let float =
  let open Angstrom in
  spaces
  *> list [ option '+' @@ char '-' >>| Char.to_string; take_while1 is_digit ]
  >>| String.concat "" %> float_of_string

let mul_op =
  let open Angstrom in
  spaces *> (char '*' *> return `Mul <|> char '/' *> return `Div)

let sum_op =
  let open Angstrom in
  spaces *> (char '+' *> return `Add <|> char '-' *> return `Sub)

let combine =
  List.fold_left (fun acc (op, num) ->
      ( match op with
      | `Add -> ( +. )
      | `Sub -> ( -. )
      | `Div -> ( /. )
      | `Mul -> ( *. ) )
        acc
        num)

let expr =
  let open Angstrom in
  fix (fun e ->
      let atom = float <|> (spaces *> char '(' *> e <* spaces <* char ')') in
      let factor = combine <$> atom <*> many (Pair.make <$> mul_op <*> atom) in
      let sum = combine <$> factor <*> many (Pair.make <$> sum_op <*> factor) in
      sum)

let parser =
  let open Angstrom in
  take_till (Char.equal ' ') >>= function
  | "ping" -> return Ping
  | "calc" -> expr >>| fun f -> Calc f
  | other -> fail (Printf.sprintf "unrecognized command %S" other)

let handle_command proxy conv = function
  | Ping ->
      let+ () = Logs_lwt.app (fun m -> m "got ping command")
      and+ _ = Conversation.send proxy conv "pong" in
      ()
  | Calc f ->
      let+ () = Logs_lwt.app (fun m -> m "got calc")
      and+ _ = Conversation.send proxy conv @@ Float.to_string f in
      ()

let handle proxy msg =
  match String.chop_prefix ~pre:"/k " msg.Message.body with
  | None -> Lwt.return ()
  | Some s -> (
      match Angstrom.parse_string ~consume:All parser s with
      | Error err ->
          let+ () =
            Logs_lwt.app (fun m ->
                m "failed to parse command string %S%s" s err)
          and+ _ =
            Conversation.send
              proxy
              msg.conversation
              (Printf.sprintf "failed to parse command string %S%s" s err)
          in
          ()
      | Ok cmd -> handle_command proxy msg.conversation cmd )
