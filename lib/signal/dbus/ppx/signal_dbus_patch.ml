open Ppxlib
open Containers
module Seen = Set.Make (String)

let signal_member_label label =
  match label with
  | { pld_name = { txt = "m_sendMessage"; _ }
    ; pld_type =
        [%type:
          'a OBus_object.t -> string * string list * string -> int64 Lwt.t]
    ; _
    } -> None
  | _ -> Some label

let get_type_members = function
  | [ ( { ptype_name = { txt = "members"; _ }
        ; ptype_params = [ ([%type: 'a], Invariant) ]
        ; ptype_kind = Ptype_record labels
        ; _
        } as t )
    ] ->
      let labels' = List.filter_map signal_member_label labels in
      Some [ { t with ptype_kind = Ptype_record labels' } ]
  | _ -> None

let intf_item = function
  | [%sigi:
      module Org_asamk_Signal : [%m?
      { pmty_desc = Pmty_signature items; _ } as mod_type]] as mod_item ->
      let items' =
        let open List.Infix in
        let+ signal_item = items in
        match signal_item with
        | { psig_desc = Psig_type (rec_flag, types); _ } -> (
            match get_type_members types with
            | Some types' ->
                { signal_item with psig_desc = Psig_type (rec_flag, types') }
            | None -> signal_item )
        | _ -> signal_item
      in
      let loc = mod_item.psig_loc in
      [%sigi:
        module Org_asamk_Signal : [%m
        { mod_type with pmty_desc = Pmty_signature items' }]]
  | item -> item

let signal_impl_item item =
  match item with
  | { pstr_desc = Pstr_type (rec_flag, types); _ } -> (
      match get_type_members types with
      | Some types' ->
          Some { item with pstr_desc = Pstr_type (rec_flag, types') }
      | None -> Some item )
  | _ -> Some item

let impl_item item =
  match item with
  | [%stri
      module Org_asamk_Signal =
      [%m?
      { pmod_desc = Pmod_structure items; _ } as mod_expr]] ->
      let items' = List.filter_map signal_impl_item items in
      let loc = item.pstr_loc in
      [%stri
        module Org_asamk_Signal =
        [%m
        { mod_expr with pmod_desc = Pmod_structure items' }]]
  | _ -> item

(*
let impl_item = function
  | { pstr_desc =
        Pstr_module
          ({ pmb_expr = { pmod_desc = Pmod_structure items; _ }; _ } as pmb)
    ; _
    } as pstr ->
      let _, items' =
        List.fold_filter_map
          (fun seen -> function
            | [%stri
                let [%p? { ppat_desc = Ppat_var { txt = var; _ }; _ }] = [%e? _]]
              as item ->
                if Seen.mem var seen then (seen, None)
                else (Seen.add var seen, Some item)
            | item -> (seen, Some item))
          Seen.empty
          items
      in
      { pstr with
        pstr_desc =
          Pstr_module
            { pmb with
              pmb_expr = { pmb.pmb_expr with pmod_desc = Pmod_structure items' }
            }
      }
  | a -> a

let intf_item = function
  | { psig_desc =
        Psig_module
          ({ pmd_type = { pmty_desc = Pmty_signature items; _ }; _ } as pmd)
    ; _
    } as psig ->
      let _, items' =
        List.fold_filter_map
          (fun seen item ->
            match item.psig_desc with
            | Psig_value { pval_name = { txt = var; _ }; _ } ->
                Printf.printf "%S %b\n" var (Seen.mem var seen)
                ; if Seen.mem var seen then (seen, None)
                  else (Seen.add var seen, Some item)
            | _ -> (seen, Some item))
          Seen.empty
          items
      in
      { psig with
        psig_desc =
          Psig_module
            { pmd with
              pmd_type = { pmd.pmd_type with pmty_desc = Pmty_signature items' }
            }
      }
  | a -> a
  *)

let () =
  Driver.register_transformation
    ~impl:(List.map impl_item)
    ~intf:(List.map intf_item)
    "signal_dbus_patch"
