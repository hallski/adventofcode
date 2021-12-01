defmodule AdventOfCode.Y2021.Day1 do
  def test_data() do
    """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """
  end

  def real_data() do
    AdventOfCode.Helpers.Data.read_from_file("2021/day1.txt")
  end

  def run1(data) do
    parse_input(data)
    |> sum_increases()
  end

  def run2(data) do
    parse_input(data)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn l -> Enum.sum(l) end)
    |> sum_increases()
  end

  defp parse_input(data) do
    data
    |> Enum.map(&String.to_integer/1)
  end

  defp sum_increases(numbers) do
    numbers
    |> Enum.zip(Enum.drop(numbers, 1))
    |> Enum.map(fn {last, current} -> if current > last, do: :increased, else: :decreased end)
    |> Enum.filter(fn i -> i == :increased end)
    |> Enum.count()
  end
end
