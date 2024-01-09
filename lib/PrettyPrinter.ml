open Ast
open Format

let print_bool ff b = if b then fprintf ff "1" else fprintf ff "0"

let print_value ff v = Format.fprintf ff "%#x" v

let print_arg ff arg =
  match arg with
  | Aconst c ->
      print_value ff c.value
  | Avar id ->
      Variable.pp ff id

let print_op ff op =
  match op with
  | And ->
      fprintf ff "AND"
  | Nand ->
      fprintf ff "NAND"
  | Or ->
      fprintf ff "OR"
  | Xor ->
      fprintf ff "XOR"

let print_exp ff e =
  match e with
  | Earg a ->
      print_arg ff a
  | Ereg x ->
      fprintf ff "REG %a" Variable.pp x
  | Enot x ->
      fprintf ff "NOT %a" print_arg x
  | Ebinop (op, x, y) ->
      fprintf ff "%a %a %a" print_op op print_arg x print_arg y
  | Emux (c, x, y) ->
      fprintf ff "MUX %a %a %a " print_arg c print_arg x print_arg y
  | Erom rom ->
      fprintf ff "ROM %d %d %a" rom.addr_size rom.word_size print_arg
        rom.read_addr
  | Eram ram ->
      fprintf ff "RAM %d %d %a %a %a %a" ram.addr_size ram.word_size print_arg
        ram.read_addr print_arg ram.write_enable print_arg ram.write_addr
        print_arg ram.write_data
  | Eselect (idx, x) ->
      fprintf ff "SELECT %d %a" idx print_arg x
  | Econcat (x, y) ->
      fprintf ff "CONCAT %a %a" print_arg x print_arg y
  | Eslice s ->
      fprintf ff "SLICE %d %d %a" s.min s.max print_arg s.arg

let print_idents ~with_size ff l =
  let pp_var ff v =
    let v_size = Variable.size v in
    if with_size && v_size <> 1 then
      fprintf ff "@[%a : %i@]" Variable.pp v v_size
    else Variable.pp ff v
  in
  pp_print_list ~pp_sep:(fun ppf () -> fprintf ppf ",@ ") pp_var ff l

let print_program ff p =
  fprintf ff "INPUT @[%a@]@."
    (print_idents ~with_size:false)
    (Hashtbl.to_seq_keys p.p_inputs |> List.of_seq) ;
  fprintf ff "OUTPUT @[%a@]@."
    (print_idents ~with_size:false)
    (Hashtbl.to_seq_keys p.p_outputs |> List.of_seq) ;
  fprintf ff "VARS @[%a@]@.IN@."
    (print_idents ~with_size:true)
    (Hashtbl.to_seq_keys p.p_vars |> List.of_seq) ;
  Hashtbl.iter
    (fun v eq -> fprintf ff "%a = %a@." Variable.pp v print_exp eq)
    p.p_eqs ;
  fprintf ff "@."
