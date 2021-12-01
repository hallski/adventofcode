defmodule AdventOfCode.Y2020.Day18 do
  @numbers 0..9 |> Enum.map(&Integer.to_string/1)

  def test_data() do
    "5 + (8 * 3 + 9 + 3 * 4 * 3)"
    #    "2 * 3 + (4 * 5)"
  end

  def run() do
    AdventOfCode.Helpers.Data.read_from_file("2020/day18.txt")
    |> Enum.map(&calculate/1)
    |> Enum.sum()
  end

  def calculate(input) do
    input
    |> parse()
    |> eval()
  end

  def parse(input) do
    input
    |> String.graphemes()
    |> Enum.reject(fn c -> c == " " end)
    |> tokenize([])
    |> add_groups()
  end

  def tokenize(input), do: tokenize(input, [])
  def tokenize([], built), do: Enum.reverse(built)

  def tokenize([")" | rest], built), do: {Enum.reverse(built), rest}

  def tokenize([peek | rest] = input, built) do
    {a, rest} =
      case peek do
        "+" ->
          {{:op, :add}, rest}

        "*" ->
          {{:op, :mult}, rest}

        "(" ->
          {g, r} = tokenize(rest, [])
          {{:group, g}, r}

        h when h in @numbers ->
          read_number(input)

        _ ->
          {{:eeh, peek}, []}
      end

    tokenize(rest, [a | built])
  end

  def read_number(input) do
    number = input |> Enum.take_while(fn x -> x in @numbers end)

    nr = Enum.join(number) |> String.to_integer()

    {{:number, nr}, Enum.drop_while(input, fn x -> x in @numbers end)}
  end

  def add_groups(l), do: add_groups(l, [])

  def add_groups([{:group, group} | rest], done),
    do: add_groups([add_groups(group, []) | rest], done)

  def add_groups([left, {:op, :add}, {:group, right} | rest], done) do
    add_groups([[left, {:op, :add}, add_groups(right, [])] | rest], done)
  end

  def add_groups([left, {:op, :add}, right | rest], done) do
    add_groups([[left, {:op, :add}, right] | rest], done)
  end

  def add_groups([], done), do: Enum.reverse(done)

  def add_groups([h | rest], done) do
    add_groups(rest, [h | done])
  end

  def eval(l), do: eval(l, 0)
  def eval([], mem), do: mem

  def eval([group | rest], 0) when is_list(group),
    do: eval(rest, eval(group, 0))

  def eval([{:number, nr} | rest], 0), do: eval(rest, nr)
  def eval([{:op, :mult} | rest], mem), do: mem * eval(rest, 0)
  def eval([{:op, :add} | rest], mem), do: mem + eval(rest, 0)
end
