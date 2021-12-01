defmodule AdventOfCode.Day11 do
  def run() do
    AdventOfCode.Helpers.Data.read_from_file("day11.txt")
    |> to_room()
    |> Stream.iterate(&iterate/1)
    |> Stream.chunk_every(2, 1)
    |> Stream.filter(fn [new, last] -> new == last end)
    |> Enum.take(1)
    |> (fn [[x, _]] -> x end).()
    |> occupied_seats()
  end

  def occupied_seats(%{seats: seats}) do
    seats
    |> Enum.filter(fn {_, state} -> state == "#" end)
    |> Enum.count()
  end

  def to_room(lines) do
    seats = lines |> Enum.with_index() |> Enum.map(&create_row/1) |> Enum.reduce(&Map.merge/2)

    %{width: String.graphemes(hd(lines)) |> Enum.count(), height: Enum.count(lines), seats: seats}
  end

  def create_row({line, row_nr}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {spot, _} -> spot != "." end)
    |> Enum.reduce(%{}, fn {spot, col}, acc -> Map.put(acc, {row_nr, col}, spot) end)
  end

  def iterate(%{seats: seats} = room) do
    new_seats =
      seats
      |> Enum.map(fn {{row, col} = pos, state} -> {pos, update_room(room, row, col, state)} end)
      |> Map.new()

    %{room | seats: new_seats}
  end

  def update_room(room, row, col, state) do
    update_room(occupied(room, row, col), state)
  end

  def update_room(occupied, state) when occupied == 0 and state == "L", do: "#"
  def update_room(occupied, state) when occupied >= 5 and state == "#", do: "L"
  def update_room(_, state), do: state

  def occupied(room, row, col) do
    ["N", "E", "S", "W", "NW", "NE", "SE", "SW"]
    |> Enum.map(fn direction -> occupied(room, direction, row, col) end)
    |> Enum.reduce(&(&1 + &2))
  end

  def check_dir(%{height: height, width: width}, _, row, col)
      when row < 0 or row >= height or col < 0 or col >= width do
    0
  end

  def check_dir(%{seats: seats} = room, direction, row, col) do
    case Map.get(seats, {row, col}) do
      nil -> occupied(room, direction, row, col)
      "#" -> 1
      "L" -> 0
    end
  end

  def occupied(room, "N", row, col), do: check_dir(room, "N", row - 1, col)
  def occupied(room, "E", row, col), do: check_dir(room, "E", row, col + 1)
  def occupied(room, "S", row, col), do: check_dir(room, "S", row + 1, col)
  def occupied(room, "W", row, col), do: check_dir(room, "W", row, col - 1)
  def occupied(room, "NW", row, col), do: check_dir(room, "NW", row - 1, col - 1)
  def occupied(room, "NE", row, col), do: check_dir(room, "NE", row - 1, col + 1)
  def occupied(room, "SE", row, col), do: check_dir(room, "SE", row + 1, col + 1)
  def occupied(room, "SW", row, col), do: check_dir(room, "SW", row + 1, col - 1)
end
