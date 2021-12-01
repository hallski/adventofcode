defmodule AdventOfCode.Day12_1 do
  def test_data() do
    """
    F10
    N3
    F7
    R90
    F11
    """
    |> String.split("\n", trim: true)
  end

  # Data structure is {position, direction} where both position and direction are {west, north}
  def run() do
    # test_data()
    AdventOfCode.Helpers.Data.read_from_file("day12.txt")
    |> iterate()
    |> IO.inspect()
    |> distance()
  end

  def distance({west, north}), do: abs(west) + abs(north)

  def iterate(instructions) do
    iterate(instructions, {{0, 0}, {1, 0}}, [])
  end

  def iterate([], {position, _}, history) do
    IO.inspect(history, label: History)
    position
  end

  def iterate([h | t], boat, history) do
    new_boat = execute(h, boat)
    iterate(t, new_boat, [new_boat | history])
  end

  def execute(<<instr::binary-size(1), distance::binary>>, boat) do
    execute(instr, String.to_integer(distance), boat)
  end

  def execute("N", distance, boat), do: execute({0, 1}, distance, boat)
  def execute("S", distance, boat), do: execute({0, -1}, distance, boat)
  def execute("W", distance, boat), do: execute({-1, 0}, distance, boat)
  def execute("E", distance, boat), do: execute({1, 0}, distance, boat)

  def execute("F", distance, {_, direction} = boat),
    do: execute(direction, distance, boat)

  def execute("R", 0, boat), do: boat

  def execute("R", degrees, {pos, direction}) do
    new_direction =
      case direction do
        {1, 0} -> {0, -1}
        {0, -1} -> {-1, 0}
        {-1, 0} -> {0, 1}
        {0, 1} -> {1, 0}
      end

    execute("R", degrees - 90, {pos, new_direction})
  end

  def execute("L", 0, boat), do: boat

  def execute("L", degrees, {pos, direction}) do
    new_direction =
      case direction do
        {1, 0} -> {0, 1}
        {0, 1} -> {-1, 0}
        {-1, 0} -> {0, -1}
        {0, -1} -> {1, 0}
      end

    execute("L", degrees - 90, {pos, new_direction})
  end

  def execute({west, north}, distance, {{pos_w, pos_n}, direction}) do
    {{pos_w + west * distance, pos_n + north * distance}, direction}
  end
end
