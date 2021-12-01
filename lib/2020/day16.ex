defmodule AdventOfCode.Y2020.Day16 do
  def run(input) do
    input
    |> String.split("\n\n", trim: true)
    |> AdventOfCode.Y2020.Day16.Parser.parse()
  end

  def run1() do
    AdventOfCode.Helpers.Data.read_from_file_no_split("2020/day16.txt")
    |> run()
    |> part1()
  end

  def run2() do
    AdventOfCode.Helpers.Data.read_from_file_no_split("2020/day16.txt")
    |> run()
    |> part2()
  end

  def part1(%{fields: fields, nearby: nearby}) do
    nearby
    |> Enum.flat_map(&identify_invalid(&1, fields))
    |> Enum.sum()
  end

  def part2(%{fields: fields, nearby: nearby, my_ticket: my_ticket}) do
    nearby
    |> Enum.filter(&is_valid_ticket?(&1, fields))
    |> get_index_field_combinations(fields)
    |> map_field_to_index()
    |> product_of_departure_fields(my_ticket)
  end

  def product_of_departure_fields(fields, my_ticket) do
    fields
    |> Enum.filter(fn {k, _v} -> String.contains?(k, "departure") end)
    |> Enum.reduce(1, fn {_, pos}, acc -> acc * Enum.at(my_ticket, pos) end)
  end

  def get_index_field_combinations(valid_tickets, fields) do
    nr_of_fields = Enum.count(fields)

    combinations =
      for i <- 0..(nr_of_fields - 1),
          f <- fields,
          is_valid_for_all_tickets?(valid_tickets, i, f),
          do: {i, f}

    combinations
    |> Enum.chunk_by(fn {pos, _} -> pos end)
    |> Enum.map(&get_pos_names/1)
  end

  def get_pos_names(list) do
    {pos, _} = hd(list)
    names = list |> Enum.map(fn {_, %{name: name}} -> name end) |> MapSet.new()

    {pos, names}
  end

  def map_field_to_index(list) do
    {order, _} =
      list
      |> Enum.sort(fn {_, a}, {_, b} -> MapSet.size(a) < MapSet.size(b) end)
      |> Enum.reduce({%{}, MapSet.new()}, fn {pos, names}, {acc, taken} ->
        name =
          names
          |> MapSet.difference(taken)
          |> MapSet.to_list()
          |> List.first()

        {Map.put(acc, name, pos), MapSet.put(taken, name)}
      end)

    order
  end

  def is_valid_for_all_tickets?(tickets, pos, %{intervals: intervals}) do
    tickets
    |> Enum.map(&Enum.at(&1, pos))
    |> Enum.all?(&is_valid_field?(&1, intervals))
  end

  def is_valid_field?(nr, ranges) do
    ranges |> Enum.any?(fn r -> nr in r end)
  end

  def is_valid_ticket?(ticket, fields) do
    identify_invalid(ticket, fields)
    |> Enum.empty?()
  end

  def identify_invalid(ticket, fields) do
    intervals = fields |> Enum.flat_map(fn %{intervals: intervals} -> intervals end)

    ticket
    |> Enum.reject(fn nr -> is_valid_field?(nr, intervals) end)
  end
end

defmodule AdventOfCode.Y2020.Day16.Parser do
  def parse([fields, my_ticket, nearby]) do
    %{
      :fields => parse_fields(fields),
      :my_ticket => parse_my_ticket(my_ticket),
      :nearby => parse_nearby(nearby)
    }
  end

  def parse_fields(fields) do
    # For each row, read through with regexp
    fields
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_field/1)
  end

  def parse_field(field) do
    [name, a_start, a_end, b_start, b_end] =
      Regex.run(~r/^(.*): (\d+)-(\d+) or (\d+)-(\d+)$/, field, capture: :all_but_first)

    [a_start, a_end, b_start, b_end] =
      [a_start, a_end, b_start, b_end] |> Enum.map(&String.to_integer/1)

    %{:name => name, intervals: [a_start..a_end, b_start..b_end]}
  end

  def parse_my_ticket(my_ticket) do
    my_ticket
    |> String.split("\n", trim: true)
    |> Enum.at(1)
    |> parse_ticket()
  end

  def parse_nearby(nearby) do
    nearby
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&parse_ticket/1)
  end

  def parse_ticket(ticket_data) do
    ticket_data
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
