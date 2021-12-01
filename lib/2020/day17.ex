defmodule AdventOfCode.Y2020.Day17 do
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

  # Store in a MapSet on {x,y,z}
  # Keep track of outer bounds and check each coordinate for outer bounds + 1

  def run() do
    start_data()
    |> run()
  end

  def run(input) do
    input
    |> parse()
    |> simulate(6)
    |> Kernel.map_size()
  end

  def simulate(pocket, 0), do: pocket

  def simulate(pocket, iterations) do
    new_pocket =
      pocket
      |> simulate_one
      |> Enum.filter(fn {_, state} -> state == "#" end)
      |> Enum.into(%{})

    simulate(new_pocket, iterations - 1)
  end

  def simulate_one(pocket) do
    [x_range, y_range, z_range, w_range] = simulation_space(pocket)

    for x <- x_range,
        y <- y_range,
        z <- z_range,
        w <- w_range do
      coordinate = {x, y, z, w}
      {coordinate, new_state(pocket, coordinate)}
    end
  end

  def simulation_space(pocket) do
    x_range = pocket |> Enum.map(fn {{x, _, _, _}, _} -> x end) |> Enum.min_max()
    y_range = pocket |> Enum.map(fn {{_, y, _, _}, _} -> y end) |> Enum.min_max()
    z_range = pocket |> Enum.map(fn {{_, _, z, _}, _} -> z end) |> Enum.min_max()
    w_range = pocket |> Enum.map(fn {{_, _, _, w}, _} -> w end) |> Enum.min_max()

    sim_range = fn {min, max} -> (min - 1)..(max + 1) end

    [x_range, y_range, z_range, w_range] |> Enum.map(sim_range)
  end

  def new_state(pocket, coordinate) do
    state = Map.get(pocket, coordinate, ".")
    active_neighbours = get_active_neighbours(pocket, coordinate)
    state(state, active_neighbours)
  end

  def state("#", neighbors) when neighbors in 2..3, do: "#"
  def state(".", 3), do: "#"
  def state(_, _), do: "."

  def get_active_neighbours(pocket, {x, y, z, w}) do
    check_range = fn n -> (n - 1)..(n + 1) end

    for(
      xp <- check_range.(x),
      yp <- check_range.(y),
      zp <- check_range.(z),
      wp <- check_range.(w),
      {x, y, z, w} != {xp, yp, zp, wp},
      do: Map.get(pocket, {xp, yp, zp, wp}, ".")
    )
    |> Enum.filter(fn state -> state == "#" end)
    |> Enum.count()
  end

  def parse(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {data, y} ->
      String.split(data, "", trim: true)
      |> Enum.with_index()
      |> Enum.filter(fn {state, _} -> state == "#" end)
      |> Enum.map(fn {state, x} -> {{x, y, 0, 0}, state} end)
    end)
    |> Map.new()
  end
end
