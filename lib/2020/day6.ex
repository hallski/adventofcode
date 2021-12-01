defmodule AdventOfCode.Y2020.Day6 do
  alias AdventOfCode.Helpers.Data
  def run1(), do: run(fn group -> process_group(group, &MapSet.union/2) end)
  def run2(), do: run(fn group -> process_group(group, &MapSet.intersection/2) end)

  defp run(group_processor) do
    "2020/day6.txt"
    |> Data.read_from_file_no_split()
    |> String.split("\n\n", trim: true)
    |> Enum.map(group_processor)
    |> Enum.reduce(0, &(&1 + &2))
  end

  defp process_group(group_data, reducer) do
    group_data
    |> String.split("\n", trim: true)
    |> Enum.map(&answers_to_set/1)
    |> Enum.reduce(reducer)
    |> MapSet.size()
  end

  defp answers_to_set(member) do
    member
    |> String.split("", trim: true)
    |> MapSet.new()
  end
end
