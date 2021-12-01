defmodule AdventOfCode.Day1 do
  alias AdventOfCode.Helpers.Data

  defp get_numbers() do
    Data.read_from_file("2020/day1.txt")
    |> Enum.map(&String.to_integer/1)
  end

  def run1() do
    get_numbers()
    |> find_pair(2020)
    |> List.first()
  end

  def run2() do
    get_numbers()
    |> find_triplet(2020)
    |> List.first()
  end

  def find_pair(list, sum) do
    for x <- list,
        y <- list,
        x != y,
        x + y == sum,
        do: x * y
  end

  def find_triplet(list, sum) do
    for x <- list,
        y <- list,
        z <- list,
        x != y != z,
        x + y + z == sum,
        do: x * y * z
  end
end

# Read the file
# Parse each line as a number
# Find two numbers that adds up to 2020
# Multiply the numbers and output
answer = AdventOfCode.Day1.run1()
IO.puts("Answer 1: #{answer}")

answer = AdventOfCode.Day1.run2()
IO.puts("Answer 2: #{answer}")
