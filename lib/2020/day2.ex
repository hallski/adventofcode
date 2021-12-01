defmodule AdventOfCode.Day2 do
  alias AdventOfCode.Helpers.Op
  alias AdventOfCode.Helpers.Data

  defp process_line(line) do
    line
    |> String.split(~r/[ :\-]/, trim: true)
    |> (fn [first, second, letter, password] ->
          {String.to_integer(first), String.to_integer(second), letter, password}
        end).()
  end

  defp run(check) do
    Data.read_from_file("2020/day2.txt")
    |> Enum.map(&process_line/1)
    |> Enum.count(check)
  end

  def run1(), do: run(&part1_check/1)
  def run2(), do: run(&part2_check/1)

  def part1_check({min, max, letter, password}) do
    nr_of_occurances =
      String.graphemes(password)
      |> Enum.filter(fn c -> c == letter end)
      |> Enum.count()

    nr_of_occurances >= min and nr_of_occurances <= max
  end

  def part2_check({pos1, pos2, letter, password}) do
    Op.xor(String.at(password, pos1 - 1) == letter, String.at(password, pos2 - 1) == letter)
  end
end

answer = AdventOfCode.Day2.run1()
IO.puts("The answer to part 1 is #{answer}")

answer = AdventOfCode.Day2.run2()
IO.puts("The answer to part 2 is #{answer}")
