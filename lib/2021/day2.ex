defmodule AdventOfCode.Y2021.Day2 do
  alias AdventOfCode.Helpers.Data

  @data_file "2020/day2.txt"

  def run1() do
    Data.read_from_file_no_split(@data_file)
    |> process1()
  end

  def run2() do
    Data.read_from_file_no_split(@data_file)
    |> process2()
  end

  def process1(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{h: 0, d: 0}, &move1/2)
    |> calc_position
  end

  def process2(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{h: 0, d: 0, aim: 0}, &move2/2)
    |> calc_position
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
  end

  def calc_position(%{:h => h, :d => d}), do: h * d

  def move1("forward " <> steps, %{:h => h} = p) do
    steps = String.to_integer(steps)
    %{p | h: h + steps}
  end

  def move1("up " <> steps, %{:d => d} = p) do
    steps = String.to_integer(steps)
    %{p | d: d - steps}
  end

  def move1("down " <> steps, %{:d => d} = p) do
    steps = String.to_integer(steps)
    %{p | d: d + steps}
  end

  def move2("forward " <> steps, %{:h => h, :d => d, :aim => aim} = p) do
    steps = String.to_integer(steps)
    %{p | h: h + steps, d: d + aim * steps}
  end

  def move2("up " <> steps, %{:aim => aim} = p) do
    steps = String.to_integer(steps)
    %{p | aim: aim - steps}
  end

  def move2("down " <> steps, %{:aim => aim} = p) do
    steps = String.to_integer(steps)
    %{p | aim: aim + steps}
  end
end
