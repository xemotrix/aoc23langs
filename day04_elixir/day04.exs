defmodule Main do
  def score_line(winning, numbers) do
    numbers
    |> Enum.map(fn n ->
      if Enum.any?(winning, fn w -> w == n end), do: 1, else: 0
    end)
    |> Enum.sum()
  end

  def parse(input) do
    String.split(input, "\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      [_, card] = String.split(line, ":")
      card
    end)
    |> Enum.map(fn card ->
      String.split(card, "|")
    end)
    |> Enum.map(fn [l, l2] ->
      {l |> String.trim() |> String.split(), l2 |> String.trim() |> String.split()}
    end)
    |> Enum.map(fn {l, l2} -> score_line(l, l2) end)
  end

  def update_card_count(_, 0, ccs), do: ccs
  def update_card_count(fac, nw, []), do: List.duplicate(fac, nw)
  def update_card_count(fac, nw, [cc | ccs]), do: [cc + fac | update_card_count(fac, nw - 1, ccs)]

  def aux([_], [cc]), do: cc

  def aux([score | scores], [cc | ccs]) do
    updated = update_card_count(cc, score, ccs)
    cc + aux(scores, updated)
  end

  def part2(input) do
    cc = List.duplicate(1, Enum.count(input))
    aux(input, cc)
  end

  def part1(input) do
    input
    |> Enum.map(fn x -> if x == 0, do: 0, else: :math.pow(2, x - 1) end)
    |> Enum.sum()
  end

  def main(input) do
    parsed = parse(input)
    IO.puts("part1: #{part1(parsed)}")
    IO.puts("part2: #{part2(parsed)}")
  end
end

case File.read("input.txt") do
  {:error, err} ->
    IO.puts("Error reading file: #{err}")

  {:ok, input} ->
    Main.main(input)
end
