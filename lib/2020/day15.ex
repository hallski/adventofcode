defmodule AdventOfCode.Y2020.Day15 do
  @end_turn 30_000_000 - 1

  def run() do
    run("0,12,6,13,20,1,17")
  end

  def run(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> iterate(0, %{})
  end

  def iterate([speak], @end_turn, _history), do: speak

  def iterate([speak], turn, history) do
    next = turn - Map.get(history, speak, turn)
    iterate([next], turn + 1, Map.put(history, speak, turn))
  end

  def iterate([speak | rest], turn, history) do
    iterate(rest, turn + 1, Map.put(history, speak, turn))
  end
end
