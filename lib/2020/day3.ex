defmodule AdventOfCode.Day3 do
  defstruct column: 0, row: 0, nr_of_rows: 0, nr_of_columns: 0, rows: [], visited: []

  alias AdventOfCode.Day3
  alias AdventOfCode.Helpers.Data

  @data Data.read_from_file("2020/day3.txt")

  def run() do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(&run_slope/1)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def run_slope(slope) do
    @data
    |> setup_state()
    |> loop(slope)
    |> calculate_trees()
  end

  defp setup_state(lines) do
    rows = Enum.map(lines, &String.graphemes/1)
    nr_of_columns = rows |> List.first() |> Enum.count()

    %Day3{
      nr_of_rows: Enum.count(lines),
      rows: rows,
      nr_of_columns: nr_of_columns
    }
  end

  defp loop(%Day3{} = state, _) when state.row >= state.nr_of_rows - 1, do: state

  defp loop(%Day3{} = state, movement) when state.column >= state.nr_of_columns do
    state
    |> extend_map()
    |> loop(movement)
  end

  defp loop(%Day3{} = state, {x, y} = movement) do
    column = state.column + x
    row = state.row + y

    new_state = %{state | row: row, column: column, visited: [{column, row} | state.visited]}

    loop(new_state, movement)
  end

  defp calculate_trees(%Day3{} = state) do
    state.visited
    |> Enum.filter(fn {col, row} -> is_tree(state, col, row) end)
    |> Enum.count()
  end

  # From https://elixirforum.com/t/advent-of-code-2020-day-3/35948/9
  # Instead of building up the map and extending it, use Stream.cycle/1
  # to indefinitely cycle each row when looking for the correct column
  defp is_tree(state, col, row) do
    state.rows
    |> Enum.at(row)
    |> Enum.at(col)
    |> (fn v -> v == "#" end).()
  end

  defp extend_map(%Day3{} = state) do
    new_map = Enum.map(state.rows, fn row -> Enum.concat(row, row) end)
    nr_of_columns = new_map |> List.first() |> Enum.count()
    %Day3{state | rows: new_map, nr_of_columns: nr_of_columns}
  end
end
