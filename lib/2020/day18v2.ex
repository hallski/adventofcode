defmodule AdventOfCode.Day18v2 do
  @supported_ops ["+", "-", "*", "/"]

  def run() do
    AdventOfCode.Helpers.Data.read_from_file("day18.txt")
    |> Enum.map(&calculate/1)
    |> Enum.sum()
  end

  def calculate(input) do
    input
    |> parse()
    |> rpn()
  end

  def parse(input) do
    input
    |> String.replace(" ", "")
    |> String.graphemes()
    |> read()
  end

  def precedence(operator) do
    case operator do
      # Change to 3 to run AoC part 1 and to 4 to run the AoC part 2
      "+" -> 2
      "-" -> 2
      "*" -> 3
      "/" -> 3
    end
  end

  def rpn(l), do: rpn(l, [])

  def rpn([], [result]), do: result

  def rpn([operator | rest], [a, b | stack]) when operator in @supported_ops do
    res =
      case operator do
        "+" -> a + b
        "-" -> b - a
        "*" -> a * b
        "/" -> b / a
      end

    rpn(rest, [res | stack])
  end

  def rpn([n | rest], stack), do: rpn(rest, [n | stack])

  # Transform infix notation to reverse polish notation
  # using Dijkstras https://en.wikipedia.org/wiki/Shunting-yard_algorithm
  def read(input), do: read(input, %{out: [], ops: []})

  def read([], %{out: out, ops: ops}) do
    ops |> Enum.reverse() |> Enum.concat(out) |> Enum.reverse()
  end

  def read([token | rest] = input, %{ops: ops, out: out} = output) do
    case token do
      "(" ->
        read(rest, %{output | ops: [token | ops]})

      ")" ->
        read(rest, pop_until("(", output))

      op when op in @supported_ops ->
        read(rest, push_op(op, output))

      _ ->
        {nr, remaining} = read_number(input)
        read(remaining, %{output | out: [nr | out]})
    end
  end

  def pop_until(token, %{ops: [operator | rest]} = output) when operator == token do
    %{output | ops: rest}
  end

  def pop_until(token, %{out: out, ops: [h | rest]}),
    do: pop_until(token, %{out: [h | out], ops: rest})

  def push_op(token, %{ops: []} = output) do
    %{output | ops: [token]}
  end

  def push_op(operator, %{out: out, ops: [s_operator | rest] = ops}) do
    cond do
      s_operator == "(" ->
        %{out: out, ops: [operator, s_operator | rest]}

      precedence(s_operator) >= precedence(operator) ->
        push_op(operator, %{out: [s_operator | out], ops: rest})

      true ->
        %{out: out, ops: [operator | ops]}
    end
  end

  # Parse number
  @numbers String.graphemes("0123456789")

  def read_number(input), do: read_number(input, [])
  def read_number([h | rest], res) when h in @numbers, do: read_number(rest, [h | res])

  def read_number(remaining, res) do
    nr = res |> Enum.reverse() |> Enum.join() |> String.to_integer()
    {nr, remaining}
  end
end
