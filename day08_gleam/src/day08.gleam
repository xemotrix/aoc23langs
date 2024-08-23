import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Graph =
  dict.Dict(String, #(String, String))

pub type Move {
  L
  R
}

pub fn main() {
  let input =
    simplifile.read("input.txt")
    |> result.unwrap("")

  use #(moves, graph) <- result.try(parse(input))

  case part1(graph, "AAA", moves, 0, fn(x) { x == "ZZZ" }) {
    Ok(n) -> io.println("Part 1: " <> int.to_string(n))
    Error(_) -> io.println("Error on part1 ")
  }

  case part2(graph, moves) {
    Ok(n) -> io.println("Part 2: " <> int.to_string(n))
    Error(_) -> io.println("Error on part2 ")
  }

  Ok(0)
}

fn part2(graph: Graph, moves: List(Move)) {
  use periods <- result.try(
    dict.keys(graph)
    |> list.filter(fn(k) { string.ends_with(k, "A") })
    |> list.map(fn(k) { part1(graph, k, moves, 0, string.ends_with(_, "Z")) })
    |> result.all(),
  )
  list.reduce(periods, lcm)
}

fn lcm(a: Int, b: Int) {
  a * b / gcd(a, b)
}

fn gcd(a: Int, b: Int) {
  case a {
    0 -> b
    _ -> gcd(b % a, a)
  }
}

fn part1(
  graph: Graph,
  current: String,
  moves: List(Move),
  count: Int,
  is_end: fn(String) -> Bool,
) {
  let recur = fn(curr, m) {
    part1(graph, curr, list.append(list.drop(moves, 1), [m]), count + 1, is_end)
  }
  case is_end(current) {
    True -> Ok(count)
    False -> {
      use #(l, r) <- result.try(dict.get(graph, current))
      use move <- result.try(list.first(moves))
      case move {
        R -> recur(r, R)
        L -> recur(l, L)
      }
    }
  }
}

fn parse(input: String) {
  let lines = string.split(input, "\n")
  use #(first, rest) <- result.try(list.pop(lines, fn(_) { True }))

  let moves = parse_moves(first)
  use #(_, rest) <- result.try(list.pop(rest, fn(_) { True }))
  let lines = list.map(rest, parse_line)

  Ok(#(moves, dict.from_list(lines)))
}

fn parse_moves(input: String) -> List(Move) {
  string.to_graphemes(input)
  |> list.map(fn(x) {
    case x {
      "L" -> L
      "R" -> R
      _ -> panic as "unreachable"
    }
  })
}

fn parse_line(input: String) -> #(String, #(String, String)) {
  let graph = string.to_graphemes(input)
  let a = list.take(graph, 3) |> string.join("")
  let graph = list.drop(graph, 3)
  let _ = list.take(graph, 4)
  let graph = list.drop(graph, 4)
  let b = list.take(graph, 3) |> string.join("")
  let graph = list.drop(graph, 3)
  let _ = list.take(graph, 2)
  let graph = list.drop(graph, 2)
  let c = list.take(graph, 3) |> string.join("")
  #(a, #(b, c))
}
