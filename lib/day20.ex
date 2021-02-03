defmodule AdventOfCode.Day20 do
  alias AdventOfCode.Day20.Parser
  alias AdventOfCode.Day20.Matrix
  alias AdventOfCode.Day20.Tile

  def run(file_name) do
    AdventOfCode.Helpers.Data.read_from_file_no_split(file_name)
    |> Parser.parse()
    |> arrange_tiles()
  end

  @all_orientations [
    :hflip,
    :vflip,
    :hflip,
    :rotate90,
    :hflip,
    :vflip,
    :hflip
  ]

  def run_both() do
    arranged_tiles = run("day20.txt")

    {solve1(arranged_tiles), solve2(arranged_tiles)}
  end

  def run1(file_name) do
    run(file_name)
    |> solve1()
  end

  def run2(file_name) do
    run(file_name)
    |> solve2()
  end

  def solve1(arranged_tiles) do
    arranged_tiles
    |> get_corners()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(fn nr, acc -> nr * acc end)
  end

  def solve2(arranged_tiles) do
    arranged_tiles
    |> create_map()
    |> find_sea_monsters()
  end

  def create_map({tiles, width}) do
    map =
      tiles
      |> Enum.map(fn tile -> Matrix.inner(tile.matrix) end)
      |> Enum.chunk_every(width)
      |> Enum.map(&create_map_row/1)
      |> Enum.concat()

    width = map |> hd |> String.length()

    {map, width}
  end

  def create_map_row(columns) do
    columns
    |> Enum.reduce(fn col, acc -> Matrix.concat(acc, col) end)
  end

  def find_sea_monsters({map, width}) do
    hashes =
      map
      |> Enum.join()
      |> String.graphemes()
      |> Enum.filter(fn s -> s == "#" end)
      |> Enum.count()

    sea_monsters =
      @all_orientations
      |> find_sea_monsters(map, monster_regex(width))

    hashes - sea_monsters * 15
  end

  def find_sea_monsters([], _map, _monster), do: 0

  def find_sea_monsters([op | rest], map, monster) do
    case find_in_map(map, monster) do
      0 -> find_sea_monsters(rest, Matrix.apply_op(map, op), monster)
      n -> n
    end
  end

  def monster_regex(width) do
    {:ok, pattern} =
      "#.a#....##....##....###a.#..#..#..#..#..#"
      |> String.replace("a", String.duplicate(".", width - 20))
      |> Regex.compile()

    pattern
  end

  def find_in_map(map, monster) do
    map
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&regex_hunt(&1, monster))
    |> Enum.sum()
  end

  def regex_hunt(str, pattern) do
    case Regex.scan(pattern, str, return: :index) do
      [[{n, _}]] -> 1 + regex_hunt(replace_at(str, n), pattern)
      [] -> 0
    end
  end

  def replace_at(str, n) do
    str
    |> String.split_at(n)
    |> (fn {a, b} -> [a, String.graphemes(b) |> Enum.drop(1) |> Enum.join()] end).()
    |> Enum.join("0")
  end

  # Create a NxN grid of the tiles where each edge match
  def arrange_tiles(tiles) do
    grid_width = grid_width(tiles)

    grid =
      tiles
      |> horizontal([], [], grid_width)
      |> Enum.map(&Tile.apply_operations_to_matrix/1)

    {grid, grid_width}
    #  |> Enum.reverse()
  end

  def get_corners({grid, width}) do
    indexes = [0, width - 1, powpow(width) - width, powpow(width) - 1]

    grid
    |> Stream.with_index()
    |> Stream.filter(fn {_, index} -> index in indexes end)
    |> Stream.map(fn {%{id: id}, _} -> id end)
    |> Enum.to_list()
  end

  def powpow(i), do: i * i

  def horizontal([], [], fitted, _width), do: Enum.reverse(fitted)
  def horizontal([], _tried, _fitted, _width), do: nil

  def horizontal([tile | rest], tried, fitted, width) do
    case fit_tile([tile | rest ++ tried], @all_orientations, fitted, width) do
      nil -> horizontal(rest, [tile | tried], fitted, width)
      result -> result
    end
  end

  # At the end, we have found a combination that works
  def fit_tile([], _ops, fitted, _width) do
    fitted
    |> IO.inspect(label: "WE HAVE A MATCH !!!!!!")
  end

  # No orientation for this tile matched, return nil
  def fit_tile(_, [], _fitted, _width), do: nil

  def fit_tile([tile | nonfitted], [op | rest_ops], fitted, width) do
    # IO.puts("Fitting tile, left to place=#{Enum.count(nonfitted)}")

    try_next_orientation = fn ->
      fit_tile([Tile.shallow_apply(tile, op) | nonfitted], rest_ops, fitted, width)
    end

    if can_fit?(tile, fitted, width) do
      # Check if tile in this orientation resolved all the way down, otherwise try the next
      case horizontal(nonfitted, [], [tile | fitted], width) do
        nil -> try_next_orientation.()
        result -> result
      end
    else
      try_next_orientation.()
    end
  end

  def tile_apply_op(%{matrix: matrix} = tile, op) do
    %{tile | matrix: Matrix.apply_op(matrix, op)}
  end

  def can_fit?(tile, fitted, width) do
    edges_to_match = get_edges_to_match(fitted, width)

    can_fit =
      get_edges_to_match(fitted, width)
      |> Enum.all?(fn {edge, pattern} -> Tile.matching_edge?(tile, edge, pattern) end)

    if false and can_fit and Enum.count(fitted) > 0 do
      IO.puts("Fitting: #{Enum.count(fitted)}")
      Matrix.print_two(hd(fitted).matrix, tile.matrix)
      IO.inspect(edges_to_match)
      IO.inspect(Tile.get_edge(tile, :left))
      IO.puts("--------------------------------")
      IO.inspect(tile)
      IO.puts("================================")
    end

    can_fit
  end

  def get_edges_to_match(previous, width) do
    n = Enum.count(previous)

    tile_above = fn ->
      previous
      |> Enum.drop(width - 1)
      |> hd
    end

    tile_to_left = fn -> hd(previous) end

    cond do
      n == 0 ->
        []

      n < width ->
        [{:left, Tile.get_edge(tile_to_left.(), :right)}]

      rem(n, width) == 0 ->
        [{:top, Tile.get_edge(tile_above.(), :bottom)}]

      true ->
        [
          {:top, Tile.get_edge(tile_above.(), :bottom)},
          {:left, Tile.get_edge(tile_to_left.(), :right)}
        ]
    end
  end

  # Rest, need to match top and left

  # Whistles innocently
  def grid_width(tiles) do
    case Enum.count(tiles) do
      9 -> 3
      144 -> 12
    end
  end
end

defmodule AdventOfCode.Day20.Parser do
  alias AdventOfCode.Day20.Tile

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_tile/1)
  end

  def parse_tile(data) do
    [id_string | matrix_data] =
      data
      |> String.split("\n", trim: true)

    Tile.new(parse_tile_id(id_string), matrix_data)
  end

  def parse_tile_id(tile_id_string) do
    Regex.run(~r/^Tile\s(\d+)\:/, tile_id_string, capture: :all_but_first) |> hd
  end
end

defmodule AdventOfCode.Day20.Tile do
  alias AdventOfCode.Day20.Tile
  alias AdventOfCode.Day20.Matrix

  defstruct id: nil, edges: %{}, matrix: nil, operations: []

  def new(id, matrix) do
    %Tile{id: id, matrix: matrix, edges: parse_edges(matrix)}
  end

  def shallow_apply(tile, op) do
    # Update the edges and store the op in operations
    new_edges =
      tile.edges
      |> Enum.map(&apply_op_to_edge(&1, op))

    %Tile{tile | edges: new_edges, operations: [op | tile.operations]}
  end

  def apply_op_to_edge({dir, str}, :vflip) do
    case dir do
      :top -> {:bottom, str}
      :left -> {:left, String.reverse(str)}
      :bottom -> {:top, str}
      :right -> {:right, String.reverse(str)}
    end
  end

  def apply_op_to_edge({dir, str}, :hflip) do
    case dir do
      :left -> {:right, str}
      :top -> {:top, String.reverse(str)}
      :right -> {:left, str}
      :bottom -> {:bottom, String.reverse(str)}
    end
  end

  def apply_op_to_edge({dir, str}, :rotate90) do
    case dir do
      :left -> {:top, String.reverse(str)}
      :top -> {:right, str}
      :right -> {:bottom, String.reverse(str)}
      :bottom -> {:left, str}
    end
  end

  def parse_edges(matrix) do
    top = List.first(matrix)
    bottom = List.last(matrix)

    [left, right] =
      Enum.map(matrix, fn line -> {String.slice(line, 0, 1), String.slice(line, -1, 1)} end)
      |> Enum.reduce([[], []], fn {s, e}, [l, r] ->
        [[s | l], [e | r]]
      end)
      |> Enum.map(fn l -> l |> Enum.reverse() |> Enum.join() end)

    %{
      top: top,
      right: right,
      bottom: bottom,
      left: left
    }
  end

  def get_edge(tile, edge), do: tile.edges[edge]

  def matching_edge?(tile, edge, pattern), do: get_edge(tile, edge) == pattern

  # Applies the ops to the matrix, this is an optimazation to avoid having to change all of it
  # while finding the grid
  def apply_operations_to_matrix(%Tile{} = tile) do
    ops = Enum.reverse(tile.operations)

    new_matrix = Matrix.apply_ops(tile.matrix, ops)

    %Tile{tile | matrix: new_matrix, operations: []}
  end
end

defmodule AdventOfCode.Day20.Matrix do
  def apply_ops(matrix, []), do: matrix

  def apply_ops(matrix, [h | r]) do
    matrix
    |> apply_op(h)
    |> apply_ops(r)
  end

  def apply_op(matrix, :rotate90) do
    rotate(matrix)
  end

  def apply_op(matrix, :hflip) do
    matrix
    |> Enum.map(&String.reverse/1)
  end

  def apply_op(matrix, :vflip) do
    matrix
    |> Enum.reverse()
  end

  def rotate(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> rotate([])
  end

  def rotate([[] | _], new) do
    new
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&Enum.join/1)
  end

  def rotate(rows, new) do
    first = Enum.flat_map(rows, fn r -> Enum.take(r, 1) end)
    rest = Enum.map(rows, fn r -> Enum.drop(r, 1) end)

    rotate(rest, [first | new])
  end

  def matching_edge?(matrix, edge, pattern) do
    matrix
    |> get_edge(edge)
    |> Kernel.==(pattern)
  end

  def get_edge(matrix, :top), do: hd(matrix)
  def get_edge(matrix, :bottom), do: List.last(matrix)
  def get_edge(matrix, :left), do: get_column(matrix, 0)
  def get_edge(matrix, :right), do: get_column(matrix, -1)

  def get_column(matrix, col) do
    matrix
    |> Enum.map(fn line -> String.slice(line, col, 1) end)
    |> Enum.reduce([], fn s, acc -> [s | acc] end)
    |> Enum.reverse()
    |> Enum.join()
  end

  def inner(data) do
    data
    |> slice_middle()
    |> Stream.map(fn row ->
      row
      |> String.graphemes()
      |> slice_middle()
      |> Enum.join()
    end)
    |> Enum.to_list()
  end

  defp slice_middle(stream) do
    stream
    |> Stream.drop(1)
    |> Stream.drop(-1)
  end

  def concat(a, b), do: concat(a, b, [])
  def concat([], [], result), do: Enum.reverse(result)

  def concat([a_head | a_rest], [b_head | b_rest], acc) do
    concat(a_rest, b_rest, [a_head <> b_head | acc])
  end

  def print_two([], []) do
    IO.puts("-------------------------")
  end

  def print_two([a | a_rest], [b | b_rest]) do
    IO.puts("#{a}     #{b}")
    print_two(a_rest, b_rest)
  end

  def print(matrix) do
    IO.puts("--------")
    Enum.each(matrix, fn row -> IO.puts(row) end)
    IO.puts("--------\n")

    matrix
  end
end
