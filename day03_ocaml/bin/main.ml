open Core

type number =
  { value : int
  ; i_from : int
  ; i_to : int
  }
[@@deriving sexp]

type symbol =
  { value : char
  ; pos : int
  }
[@@deriving sexp]

type item =
  | Numb of number
  | Symb of symbol
[@@deriving sexp]

type elt = int * item [@@deriving sexp]

module Parser = struct
  let parse_line line =
    let rec parse_line' line pos items =
      match line with
      | c :: _rest when Char.is_digit c ->
        let strn = String.of_list @@ List.take_while line ~f:Char.is_digit in
        let len = String.length strn in
        let to_idx = pos + len in
        let item = Numb { value = Int.of_string strn; i_from = pos; i_to = to_idx - 1 } in
        parse_line' (List.slice line len (List.length line)) to_idx (item :: items)
      | '.' :: rest -> parse_line' rest (pos + 1) items
      | c :: rest ->
        let to_idx = pos + 1 in
        let item = Symb { value = c; pos : int } in
        parse_line' rest to_idx (item :: items)
      | [] -> List.rev items
    in
    let lines = parse_line' (String.to_list line) 0 [] in
    lines
  ;;

  let range = List.init ~f:Fn.id

  let parse input : (elt list, string) result =
    let lines = String.split_lines input in
    let ilines = List.zip lines @@ range (List.length lines) in
    match ilines with
    | Unequal_lengths -> Error "Unequal lengths"
    | Ok ilines ->
      Ok
        (let open List.Let_syntax in
         let%bind l, i = ilines in
         let%map e = parse_line l in
         i, e)
  ;;
end

let sum = List.fold ~init:0 ~f:( + )
let prod = List.fold ~init:1 ~f:( * )

let check_neig (ia, a) (ib, b) =
  match a, b with
  | Symb s, Numb n ->
    let adj_v = abs (ia - ib) <= 1 in
    if adj_v && Int.between s.pos ~low:(n.i_from - 1) ~high:(n.i_to + 1)
    then n.value
    else 0
  | _ -> 0
;;

let part1 input =
  let check_neigs elts elt = List.map elts ~f:(check_neig elt) |> sum in
  let open Result.Let_syntax in
  let%bind elts = Parser.parse input in
  List.map elts ~f:(check_neigs elts) |> sum |> return
;;

let part2 input =
  let check_neigs elts elt =
    let li = List.map elts ~f:(check_neig elt) in
    let filter_z = List.filter li ~f:(fun e -> e <> 0) in
    if Int.(List.length filter_z <> 2) then 0 else prod filter_z
  in
  let open Result.Let_syntax in
  let%bind elts = Parser.parse input in
  List.map elts ~f:(check_neigs elts) |> sum |> return
;;

let () =
  let input = In_channel.read_all "input.txt" in
  let open Result.Let_syntax in
  match
    let%bind p1 = part1 input in
    let%bind p2 = part2 input in
    Printf.printf "Part1: %d, Part2: %d\n" p1 p2 |> return
  with
  | Ok () -> ()
  | Error e -> failwith e
;;
