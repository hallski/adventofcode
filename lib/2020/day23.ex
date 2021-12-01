defmodule AdventOfCode.Y2020.Day23.Ring do
  defstruct current: nil, content: %{}, size: 0, min: nil, max: nil

  alias AdventOfCode.Y2020.Day23.Ring

  def new(content) do
    first = Enum.take(content, 1) |> hd
    size = Enum.count(content)

    content
    |> Stream.chunk_every(2, 1)
    |> Enum.reduce(%{}, fn pair, ll ->
      case pair do
        [a, b] -> Map.put(ll, a, b)
        [last] -> Map.put(ll, last, first)
      end
    end)
    |> new_from_mapped(first, size, Enum.min_max(content))
  end

  defp new_from_mapped(mapped, first, size, {min, max}) do
    %Ring{current: first, content: mapped, size: size, min: min, max: max}
  end

  # Reads the entire ring from current (exlusive)
  def to_list(%Ring{} = ring) do
    to_list(ring, ring.current, ring.size)
  end

  # Reads entire ring, starting from `from` (exclusive)
  def to_list(%Ring{} = ring, from) do
    to_list(ring, from, ring.size)
  end

  # Reads len items from `from` (exclusive)
  def to_list(cups, from, len), do: to_list(cups, from, len, [])

  defp to_list(_ring, _cur, 0, result), do: result |> Enum.reverse()

  defp to_list(%Ring{} = ring, cur, len, acc) do
    next = Map.get(ring.content, cur)
    to_list(ring, next, len - 1, [next | acc])
  end

  def move(%Ring{} = ring, from, len, to) do
    m = to_list(ring, from, len + 1)

    [first | _] = m
    [last, next] = m |> Enum.take(-2)

    after_insert = Map.get(ring.content, to)

    content =
      ring.content
      |> Map.put(to, first)
      |> Map.put(last, after_insert)
      |> Map.put(from, next)

    %Ring{ring | content: content}
  end

  def advance_current(%Ring{} = ring) do
    %Ring{ring | current: Map.get(ring.content, ring.current)}
  end
end

defmodule AdventOfCode.Y2020.Day23 do
  def test_input(), do: "389125467"
  def input(), do: "135468729"

  alias AdventOfCode.Y2020.Day23.Ring

  def parse(raw) do
    raw
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def run1(input) do
    input
    |> parse()
    |> solve1(100)
  end

  def run2(input) do
    input
    |> parse()
    |> solve2(1_000_000, 10_000_000)
  end

  def solve1(cups, moves) do
    cups
    |> Ring.new()
    |> get_nth_move(moves)
    |> Ring.to_list(1)
    |> Enum.drop(-1)
    |> Enum.join()
  end

  def solve2(cups, highest, moves) do
    cups
    |> add_extra_cups(highest)
    |> Ring.new()
    |> get_nth_move(moves)
    |> Ring.to_list(1, 2)
    |> Enum.reduce(&Kernel.*/2)
  end

  def add_extra_cups(cups, upto) do
    len = Enum.count(cups)
    extra_cups = if upto > len, do: (len + 1)..upto, else: []

    cups
    |> Enum.concat(extra_cups)
  end

  def get_nth_move(%Ring{} = ring, moves) do
    ring
    |> Stream.iterate(&next_move/1)
    |> Stream.drop(moves)
    |> Enum.take(1)
    |> hd()
  end

  def next_move(%Ring{} = ring) do
    triplet = Ring.to_list(ring, ring.current, 3)

    to = get_insert_idx(ring.current - 1, triplet, ring.max)

    ring
    |> Ring.move(ring.current, 3, to)
    |> Ring.advance_current()
  end

  def get_insert_idx(0, removed, highest), do: get_insert_idx(highest, removed, highest)

  def get_insert_idx(idx, removed, highest) do
    cond do
      idx in removed -> get_insert_idx(idx - 1, removed, highest)
      true -> idx
    end
  end
end
