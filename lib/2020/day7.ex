defmodule AdventOfCode.Day7 do
  defstruct type: "", children: []

  alias AdventOfCode.Day7
  alias AdventOfCode.Helpers.Data

  def run() do
    IO.puts("Part1: #{run1()}")
    IO.puts("Part2: #{run2()}")
  end

  def run1() do
    process_input()
    |> get_valid("shiny gold")
    |> Enum.count()
  end

  def run2() do
    process_input()
    |> count_bags("shiny gold")
  end

  def process_input() do
    "2020/day7.txt"
    |> Data.read_from_file()
    |> Enum.map(&parse_input/1)
    |> Enum.reduce(%{}, fn bag, acc -> Map.put(acc, bag.type, bag) end)
  end

  def count_bags(_, %Day7{children: []}), do: 0

  def count_bags(lookup, %Day7{children: children}) do
    children
    |> Enum.map(fn %{"quantity" => quantity, "type" => type} ->
      quantity * (1 + count_bags(lookup, type))
    end)
    |> Enum.reduce(&(&1 + &2))
  end

  def count_bags(lookup, type) when is_binary(type) do
    count_bags(lookup, lookup[type])
  end

  @spec parse_bag_type_content(binary) :: nil | map
  def parse_bag_type_content(child_str) do
    %{"quantity" => quantity, "type" => type} =
      Regex.named_captures(~r/^(?<quantity>\d+)\s(?<type>.*)\sbags?$/, child_str)

    %{"quantity" => String.to_integer(quantity), "type" => type}
  end

  def parse_bag(%{"type" => type, "content" => "no other bags"}), do: %Day7{type: type}

  def parse_bag(%{"type" => type, "content" => content}) do
    children =
      content
      |> String.split(", ", trim: true)
      |> Enum.map(&parse_bag_type_content/1)

    %Day7{type: type, children: children}
  end

  def parse_input(line) when is_binary(line) do
    Regex.named_captures(~r/^(?<type>.*)\sbags contain\s(?<content>.*)\.$/, line)
    |> parse_bag()
  end

  def get_valid(lookup, looking_for) do
    lookup
    |> Map.values()
    |> Enum.filter(fn bag -> bag.type != looking_for end)
    |> Enum.filter(&is_valid(&1, looking_for, lookup))
  end

  def is_valid(type, looking_for, lookup) when is_binary(type) do
    is_valid(lookup[type], looking_for, lookup)
  end

  def is_valid(%Day7{type: type}, looking_for, _) when type == looking_for, do: true
  def is_valid(%Day7{children: []}, _, _), do: false

  def is_valid(%Day7{} = bag, looking_for, lookup) do
    bag.children
    |> Enum.any?(fn child -> is_valid(child["type"], looking_for, lookup) end)
  end
end
