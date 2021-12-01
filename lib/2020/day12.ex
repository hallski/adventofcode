defmodule AdventOfCode.Y2020.Day12 do
  @data_dir Path.expand("../../data", __DIR__)

  # Data structure is {position, waypoint} where both position and waypoint are {east, north}
  @initial_boat {{0, 0}, {10, 1}}

  def distance({east, north}), do: abs(east) + abs(north)

  def run_instructions(instructions), do: run_instructions(@initial_boat, instructions)
  def run_instructions({position, _}, []), do: position
  def run_instructions(boat, [h | t]), do: boat |> execute(h) |> run_instructions(t)

  def execute(boat, <<instr::binary-size(1), distance::binary>>) do
    execute(boat, instr, String.to_integer(distance))
  end

  def execute(boat, "F", distance), do: move_position(boat, distance)

  def execute(boat, "N", distance), do: move_waypoint(boat, {0, 1}, distance)
  def execute(boat, "S", distance), do: move_waypoint(boat, {0, -1}, distance)
  def execute(boat, "W", distance), do: move_waypoint(boat, {-1, 0}, distance)
  def execute(boat, "E", distance), do: move_waypoint(boat, {1, 0}, distance)

  def execute(boat, "L", degrees), do: execute(boat, "R", 360 - degrees)

  def execute(boat, "R", 0), do: boat

  def execute({pos, {waypoint_e, waypoint_n}}, "R", degrees) do
    execute({pos, {waypoint_n, -waypoint_e}}, "R", degrees - 90)
  end

  def move_point({x, y}, {dir_x, dir_y}, distance) do
    {x + dir_x * distance, y + dir_y * distance}
  end

  def move_waypoint({position, waypoint}, direction, distance) do
    {position, move_point(waypoint, direction, distance)}
  end

  def move_position({position, waypoint}, distance) do
    {move_point(position, waypoint, distance), waypoint}
  end

  def run() do
    @data_dir
    |> Path.join("2020/day12.txt")
    |> File.read!()
    |> String.split("\n", trim: true)
    |> run_instructions()
    |> distance()
  end
end
