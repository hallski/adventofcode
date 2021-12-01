defmodule AdventOfCode.Day11_1 do
  def test_data do
    """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """
    |> String.split("\n", trim: true)
  end

  def run() do
    AdventOfCode.Helpers.Data.read_from_file("day11.txt")
    # test_data()
    |> to_room()
    |> Stream.iterate(&iterate/1)
    |> Stream.chunk_every(2, 1)
    |> Stream.filter(fn [new, last] -> new == last end)
    |> Enum.take(1)
    |> (fn [[x, _]] -> x end).()
    |> occupied_seats()
  end

  def occupied_seats(%{rows: rows}) do
    rows
    |> Enum.filter(fn {_, state} -> state == "#" end)
    |> Enum.count()
  end

  def to_room(lines) do
    rows = lines |> Enum.with_index() |> Enum.map(&create_row/1) |> Enum.reduce(&Map.merge/2)

    %{width: String.graphemes(hd(lines)) |> Enum.count(), height: Enum.count(lines), rows: rows}
  end

  def create_row({line, row_nr}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {spot, _} -> spot != "." end)
    |> Enum.reduce(%{}, fn {spot, col}, acc -> Map.put(acc, {row_nr, col}, spot) end)
  end

  def iterate(%{rows: rows} = room) do
    new_rows =
      rows
      |> Enum.map(fn {{row, col} = pos, state} -> {pos, update_room(room, row, col, state)} end)
      |> Map.new()

    %{room | rows: new_rows}
  end

  def update_room(room, row, col, state) do
    update_room(occupied(room, row, col), state)
  end

  def update_room(occupied, state) when occupied == 0 and state == "L", do: "#"
  def update_room(occupied, state) when occupied >= 4 and state == "#", do: "L"
  def update_room(_, state), do: state

  def occupied(%{rows: rows}, row, col) do
    filtered =
      for r <- (row - 1)..(row + 1),
          c <- (col - 1)..(col + 1),
          {r, c} != {row, col},
          do: Map.get(rows, {r, c})

    filtered
    |> Enum.filter(fn x -> x == "#" end)
    |> Enum.count()
  end
end
