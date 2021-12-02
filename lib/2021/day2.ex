defmodule AdventOfCode.Y2021.Day2 do
  alias AdventOfCode.Helpers.Data

  def run1() do
    Data.read_from_file_no_split("2021/day2.txt")
    |> process1()
  end

  def run2() do
    Data.read_from_file_no_split("2021/day2.txt")
    |> process2()
  end

  def process1(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{:h => 0, :d => 0}, fn val, acc -> move1(acc, val) end)
    |> calc_position
  end

  def process2(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{h: 0, d: 0, aim: 0}, fn val, acc -> move2(acc, val) end)
    |> calc_position
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
  end

  def calc_position(%{:h => h, :d => d}) do
    h * d
  end

  def move1(%{:h => h} = p, "forward " <> steps) do
    steps = String.to_integer(steps)
    %{p | :h => h + steps}
  end

  def move1(%{:d => d} = p, "up " <> steps) do
    steps = String.to_integer(steps)
    %{p | :d => d - steps}
  end

  def move1(%{:d => d} = p, "down " <> steps) do
    steps = String.to_integer(steps)
    %{p | :d => d + steps}
  end

  def move2(%{:h => h, :d => d, :aim => aim} = p, "forward " <> steps) do
    steps = String.to_integer(steps)
    %{p | :h => h + steps, :d => d + aim * steps}
  end

  def move2(%{:aim => aim} = p, "up " <> steps) do
    steps = String.to_integer(steps)
    %{p | :aim => aim - steps}
  end

  def move2(%{:aim => aim} = p, "down " <> steps) do
    steps = String.to_integer(steps)
    %{p | aim: aim + steps}
  end
end
