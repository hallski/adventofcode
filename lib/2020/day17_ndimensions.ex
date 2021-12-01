defmodule AdventOfCode.Day17.NDimensions do
  def test_data() do
    """
    .#.
    ..#
    ###
    """
  end

  def start_data() do
    """
    .#.##..#
    ....#.##
    ##.###..
    .#.#.###
    #.#.....
    .#..###.
    .#####.#
    #..####.
    """
  end

  def run(), do: run(6, 4)

  def run(iterations, dimensions) do
    start_data()
    |> run(iterations, dimensions)
  end

  def run(input, iterations, dimensions) do
    input
    |> parse(dimensions)
    |> Stream.iterate(&simulate/1)
    |> Stream.drop(iterations)
    |> Enum.take(1)
    |> hd
    |> (fn %{satellites: satellites} -> satellites end).()
    |> Kernel.map_size()
  end

  def simulate(%{space: space, satellites: satellites}) do
    simulate_plane(satellites, [], space)
  end

  def simulate_plane(pocket, coordinates, []) do
    state = new_state(pocket, coordinates)

    if state == "#" do
      %{space: coordinates |> Enum.map(fn x -> {x, x} end), satellites: %{coordinates => state}}
    else
      %{space: coordinates |> Enum.map(fn _ -> {0, 0} end), satellites: %{}}
    end
  end

  def simulate_plane(pocket, plane, [{min, max} | rest]) do
    (min - 1)..(max + 1)
    |> Enum.map(fn p -> simulate_plane(pocket, plane ++ [p], rest) end)
    |> Enum.reduce(fn %{space: space, satellites: satellites},
                      %{space: acc_space, satellites: acc_satellites} ->
      %{space: min_max(space, acc_space), satellites: Map.merge(satellites, acc_satellites)}
    end)
  end

  def min_max(a, b), do: min_max(a, b, [])
  def min_max([], [], res), do: Enum.reverse(res)

  def min_max([{amin, amax} | arest], [{bmin, bmax} | brest], res) do
    min_max(arest, brest, [Enum.min_max([amin, bmin, amax, bmax]) | res])
  end

  def new_state(pocket, coordinate) do
    state = Map.get(pocket, coordinate, ".")
    active_neighbours = get_active_neighbours(pocket, coordinate)
    state(state, active_neighbours)
  end

  def state("#", neighbors) when neighbors in 2..3, do: "#"
  def state(".", 3), do: "#"
  def state(_, _), do: "."

  def get_active_neighbours(pocket, to, coordinates, []) do
    case {to == coordinates, Map.get(pocket, coordinates)} do
      {false, "#"} -> 1
      _ -> 0
    end
  end

  def get_active_neighbours(pocket, to, coordinates, [n | rest]) do
    for(p <- (n - 1)..(n + 1), do: get_active_neighbours(pocket, to, coordinates ++ [p], rest))
    |> Enum.reduce(&(&1 + &2))
  end

  def get_active_neighbours(pocket, to), do: get_active_neighbours(pocket, to, [], to)

  def parse(data, dimensions) do
    extra_dimensions = dimensions - 2

    padding = 0..(extra_dimensions - 1) |> Enum.map(fn _ -> 0 end)
    range_padding = 0..(extra_dimensions - 1) |> Enum.map(fn _ -> {0, 0} end)

    satellites =
      data
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {data, y} ->
        String.split(data, "", trim: true)
        |> Enum.with_index()
        |> Enum.filter(fn {state, _} -> state == "#" end)
        |> Enum.map(fn {state, x} -> {[x, y] ++ padding, state} end)
      end)
      |> Map.new()

    x_range = satellites |> Enum.map(fn {[x, _ | _], _} -> x end) |> Enum.min_max()
    y_range = satellites |> Enum.map(fn {[_, y | _], _} -> y end) |> Enum.min_max()

    %{:space => [x_range, y_range] ++ range_padding, :satellites => satellites}
  end
end
