defmodule AdventOfCode.Day10 do
  @data_dir Path.expand("../data", __DIR__)

  def run() do
    @data_dir
    |> Path.join("day10.txt")
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> add_socket_and_device()
  end

  def add_socket_and_device(input), do: Enum.concat(input, [0, Enum.max(input) + 3])

  # ------
  # Part 1
  # ------
  def run1() do
    run()
    |> Enum.sort()
    |> build()
    |> checksum()
  end

  def checksum(%{jumps: %{1 => one, 3 => three}}), do: one * three

  def build([socket | adapters]), do: build(%{seq: [socket], jumps: %{}}, adapters)

  def build(%{} = result, []), do: %{result | seq: Enum.reverse(result.seq)}

  def build(%{} = acc, [head | tail]) do
    add_adapter(acc, head)
    |> build(tail)
  end

  def add_adapter(%{seq: [last | _], jumps: jumps} = data, adapter)
      when adapter - last <= 3 do
    jumps = Map.update(jumps, adapter - last, 1, fn v -> v + 1 end)
    %{data | seq: [adapter | data.seq], jumps: jumps}
  end

  # ------
  # Part 2
  # ------
  def run2() do
    run()
    |> Enum.sort(:desc)
    |> variations()
  end

  def variations([head | tail]), do: variations(tail, %{head => 1})

  # Return the accumulated value
  def variations([], collector), do: Map.get(collector, 0)

  def variations([head | tail], collector) do
    value = 1..3 |> Enum.reduce(0, fn i, acc -> Map.get(collector, head + i, 0) + acc end)

    variations(tail, Map.put(collector, head, value))
  end
end
