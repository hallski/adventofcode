defmodule AdventOfCode.Y2020.Day24 do
  def run1(input) do
    input
    |> setup_floor()
    |> count_black()
  end

  def run2(input, day) do
    input
    |> setup_floor()
    |> Stream.iterate(&apply_art_rules/1)
    |> Stream.drop(day)
    |> Enum.take(1)
    |> hd()
    |> count_black
  end

  def setup_floor(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> flip_tiles()
  end

  def get_floor_edges(tiles) do
    tiles
    |> Enum.map(fn {coordinates, _} -> coordinates end)
    |> Enum.reduce({{0, 0}, {0, 0}}, fn {x, y}, {{min_x, max_x}, {min_y, max_y}} ->
      {{min(x, min_x), max(x, max_x)}, {min(y, min_y), max(y, max_y)}}
    end)
  end

  def get_coordinates_to_check({{min_x, max_x}, {min_y, max_y}}) do
    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        do: {x, y}
  end

  def apply_art_rules(tiles) do
    tiles
    |> get_floor_edges()
    |> get_coordinates_to_check()
    |> Enum.map(fn coord -> {coord, Map.get(tiles, coord, :white)} end)
    |> Enum.map(&update_tile(&1, tiles))
    |> Enum.filter(fn {_, state} -> state == :black end)
    |> Map.new()
  end

  def update_tile({coordinate, state}, tiles) do
    new_state =
      tiles
      |> get_surrounding_tiles(coordinate)
      |> count_black()
      |> get_new_tile_color(state)

    {coordinate, new_state}
  end

  def get_new_tile_color(surrounding_black, current_state) do
    case current_state do
      :black when surrounding_black == 0 or surrounding_black > 2 -> :white
      :white when surrounding_black == 2 -> :black
      _ -> current_state
    end
  end

  def count_black(tiles) do
    tiles
    |> Enum.filter(fn {_, tile} -> tile == :black end)
    |> Enum.count()
  end

  def flip_tiles(tiles_to_flip), do: flip_tiles(Map.new(), tiles_to_flip)
  def flip_tiles(tiles, []), do: tiles

  def flip_tiles(tiles, [line | rest]) do
    tiles
    |> find_and_flip(line, {0, 0})
    |> flip_tiles(rest)
  end

  def find_and_flip(tiles, [], current), do: tiles |> flip_tile(current)

  def find_and_flip(tiles, [direction | rest], current) do
    find_and_flip(tiles, rest, get_coordinate(current, direction))
  end

  def flip_tile(tiles, coordinate) do
    tiles
    |> Map.update(coordinate, :black, fn tile ->
      case tile do
        :white -> :black
        :black -> :white
      end
    end)
  end

  def get_surrounding_tiles(tiles, coordinate) do
    coordinates =
      [:ne, :se, :nw, :sw, :e, :w]
      |> Enum.map(fn dir -> get_coordinate(coordinate, dir) end)

    Map.take(tiles, coordinates)
  end

  def get_coordinate({x, y}, dir) do
    case dir do
      :ne -> {x + rem(abs(y), 2), y + 1}
      :se -> {x + rem(abs(y), 2), y - 1}
      :nw -> {x - 1 + rem(abs(y), 2), y + 1}
      :sw -> {x - 1 + rem(abs(y), 2), y - 1}
      :e -> {x + 1, y}
      :w -> {x - 1, y}
    end
  end

  def parse_line(line), do: parse_line(line, [])
  def parse_line("", result), do: Enum.reverse(result)
  def parse_line("se" <> rest, result), do: parse_line(rest, [:se | result])
  def parse_line("sw" <> rest, result), do: parse_line(rest, [:sw | result])
  def parse_line("ne" <> rest, result), do: parse_line(rest, [:ne | result])
  def parse_line("nw" <> rest, result), do: parse_line(rest, [:nw | result])
  def parse_line("w" <> rest, result), do: parse_line(rest, [:w | result])
  def parse_line("e" <> rest, result), do: parse_line(rest, [:e | result])
end
