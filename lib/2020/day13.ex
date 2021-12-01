defmodule AdventOfCode.Day13 do
  alias AdventOfCode.Helpers.Math

  def test_data() do
    """
    939
    7,13,x,x,59,x,31,19
    """
    |> String.split("\n", trim: true)
  end

  def test_data2() do
    """
    x
    1789,37,47,1889
    """
    |> String.split("\n", trim: true)
  end

  def run() do
    x =
      AdventOfCode.Helpers.Data.read_from_file("2020/day13.txt")
      |> parse()

    clock = Stream.iterate(0, &(&1 + 1))

    clock
    |> setup_busses(x[:busses])
    |> Enum.reduce(fn bus, acc ->
      Stream.zip(acc, bus)
      |> Stream.map(fn {merged, bus} ->
        if is_list(merged), do: [bus | merged], else: [bus | [merged]]
      end)
    end)
    |> Stream.zip(clock)
    |> Stream.drop(x[:earliest])
    |> Stream.filter(fn {busses, _} ->
      Enum.any?(busses, fn bus -> bus != "." end)
    end)
    |> Enum.take(1)
    |> process_result(x[:earliest])
  end

  def process_result([{busses, timestamp}], earliest) do
    bus = Enum.find(busses, fn bus -> bus != "." end)
    wait = timestamp - earliest
    bus * wait
  end

  def parse([earliest, bus_string]) do
    busses =
      bus_string
      |> String.split(",", trim: true)
      |> Enum.filter(fn bus -> bus != "x" end)
      |> Enum.map(&String.to_integer/1)

    %{:earliest => String.to_integer(earliest), :busses => busses}
  end

  def setup_busses(source, busses) do
    busses
    |> Enum.map(fn bus ->
      Stream.map(source, fn timestamp ->
        if rem(timestamp, bus) == 0, do: bus, else: "."
      end)
    end)
  end

  def find_next({nr, offset} = bus, {timestamp, step}) do
    if rem(timestamp + offset, nr) == 0 do
      {timestamp, Math.lcm(step, nr)}
    else
      find_next(bus, {timestamp + step, step})
    end
  end

  def solve(list) do
    list |> Enum.reduce({0, 1}, &find_next/2)
  end

  def run2() do
    AdventOfCode.Helpers.Data.read_from_file("2020/day13.txt")
    |> (fn [_, busses] -> String.split(busses, ",", trim: true) end).()
    |> Enum.with_index()
    |> Enum.filter(fn {x, _} -> x != "x" end)
    |> Enum.map(fn {x, i} -> {String.to_integer(x), i} end)
    |> solve()
  end
end
