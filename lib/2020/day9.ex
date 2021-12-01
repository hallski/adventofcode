defmodule AdventOfCode.Y2020.Day9 do
  alias AdventOfCode.Helpers.Data

  @preamble_size 25
  def find_weakness() do
    key = find_key()

    Data.read_from_file("2020/day9.txt")
    |> Enum.map(&String.to_integer/1)
    |> Enum.filter(fn x -> x < key end)
    |> find_range(key)
    |> Enum.min_max()
    |> (fn {min, max} -> min + max end).()
  end

  def find_key() do
    Data.file_stream("2020/day9.txt")
    |> Stream.map(&String.to_integer(&1))
    |> Stream.chunk_every(@preamble_size + 1, 1)
    |> Stream.map(&List.pop_at(&1, -1))
    |> Enum.find(&invalid/1)
    |> (fn {nr, _} -> nr end).()
  end

  def invalid({nr, list}) do
    list
    |> find_pair(nr)
    |> Enum.count() == 0
  end

  def find_pair(list, sum) do
    for x <- list,
        y <- list,
        x != y,
        x + y == sum,
        do: {x, y}
  end

  def find_range([], _), do: []

  def find_range(list, weakness) do
    {sum, range} =
      Enum.reduce_while(list, {0, []}, fn x, {sum, range} = acc ->
        if sum >= weakness, do: {:halt, acc}, else: {:cont, {x + sum, [x | range]}}
      end)

    if sum == weakness, do: range, else: find_range(Enum.drop(list, 1), weakness)
  end
end
