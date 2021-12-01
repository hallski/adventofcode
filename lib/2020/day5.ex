defmodule AdventOfCode.Day5 do
  alias AdventOfCode.Helpers.Data

  def run1() do
    process_file()
    |> Enum.max()
  end

  def run2() do
    process_file()
    |> find_seat
  end

  def process_file() do
    "2020/day5.txt"
    |> Data.read_from_file()
    |> Enum.map(&process_boarding_pass/1)
    |> Enum.map(&calculate_seat/1)
  end

  def find_empty([{a, b} = head | tail]) do
    if b - a > 1, do: head, else: find_empty(tail)
  end

  def find_empty([_ | tail] = list) do
    list
    |> Enum.zip(tail)
    |> find_empty()
  end

  def find_seat(occupied_seats) do
    occupied_seats
    |> Enum.sort()
    |> find_empty()
    |> (fn {a, _} -> a + 1 end).()
  end

  def process_boarding_pass(<<rowseq::binary-size(7), colseq::binary-size(3)>>) do
    %{row_range: {0, 127}, col_range: {0, 7}}
    |> process_boarding_pass(String.graphemes(rowseq), String.graphemes(colseq))
  end

  def process_boarding_pass(%{row_range: {row, _}, col_range: {col, _}}, [], []), do: {row, col}

  def process_boarding_pass(%{} = d, [], [cur | tail]) do
    process_boarding_pass(%{d | col_range: split_range(cur, d.col_range)}, [], tail)
  end

  def process_boarding_pass(%{} = d, [cur | tail], colseq) do
    process_boarding_pass(%{d | row_range: split_range(cur, d.row_range)}, tail, colseq)
  end

  def split_range("L", range), do: split_range("F", range)

  def split_range("F", {min, max}) do
    {min, min + div(max - min, 2)}
  end

  def split_range("R", range), do: split_range("B", range)

  def split_range("B", {min, max}) do
    {min + div(max - min, 2) + 1, max}
  end

  def calculate_seat({row, col}), do: row * 8 + col
end
