# Turned out this was a lot faster (but also makes some assumptions)
defmodule AdventOfCode.Day20.V1 do
  alias AdventOfCode.Day20.V1.Edge
  alias AdventOfCode.Day20.V1.Parser
  alias AdventOfCode.Day20.V1.Matrix

  def run_both() do
    relations =
      "day20.txt"
      |> Parser.parse()
      |> build_relations()

    {solve1(relations), solve2(relations)}
  end

  def run1(file_name) do
    Parser.parse(file_name)
    |> build_relations()
    |> solve1()
  end

  def run2(file_name) do
    Parser.parse(file_name)
    |> build_relations()
    |> solve2()
  end

  def solve1(relations) do
    relations
    |> Enum.filter(fn {_, tile} -> is_corner?(tile) end)
    |> Enum.map(fn {id, _} -> String.to_integer(id) end)
    |> Enum.reduce(fn id, acc -> id * acc end)
  end

  def solve2(relations) do
    relations
    |> Map.new()
    |> orient_tiles()
    |> Map.values()
    |> construct_map()
    |> find_sea_monsters()
  end

  def build_relations(l), do: build_relations(l, [], [])
  def build_relations([], _, result), do: result

  def build_relations([current | rest], processed, result) do
    %{id: id, edges: edges} = current

    neighbours =
      matching_edges(edges, rest ++ processed)
      |> Enum.map(fn {edge, %{id: id}} -> {edge, id} end)

    build_relations(rest, [current | processed], [
      {id, %{current | neighbours: neighbours}} | result
    ])
  end

  def construct_map(tiles) do
    width = tiles |> Enum.count() |> :math.sqrt() |> round()

    map =
      tiles
      |> Enum.sort(fn %{pos: {ax, ay}}, %{pos: {bx, by}} ->
        width * ay + ax <= width * by + bx
      end)
      |> Enum.group_by(fn %{pos: {_, y}} -> y end)
      |> Map.values()
      |> construct_map_rows([])
      |> Enum.reverse()
      |> Enum.concat()

    Matrix.apply_ops([:hflip], map)
  end

  def construct_map_rows([], result), do: Enum.reverse(result)

  def construct_map_rows([columns | rest], acc) do
    row =
      columns
      |> Enum.map(fn %{matrix: matrix} -> Matrix.inner(matrix) end)
      |> Enum.reduce(fn col, acc -> Matrix.concat(acc, col) end)

    construct_map_rows(rest, [row | acc])
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
  def find_sea_monsters(map) do
    width = List.first(map) |> String.length()

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

  def orient_tiles(relations) do
    {_, tile} =
      relations
      |> Enum.find(fn {_, tile} -> is_corner?(tile) end)

    tile = %{tile | pos: {0, 0}}

    orient_tiles([tile], Map.put(relations, tile.id, tile))
  end

  def orient_tiles([], relations), do: relations

  def orient_tiles([tile | rest], relations) do
    updated_tiles =
      tile.neighbours
      |> Enum.map(fn {tile_edge, neighbour_id} ->
        {tile_edge, Map.get(relations, neighbour_id)}
      end)
      |> Enum.filter(fn {_, neighbour} -> neighbour.pos == nil end)
      |> Enum.map(fn {tile_edge, neighbour} ->
        connect_neighbour(tile, tile_edge, neighbour)
      end)

    updated_relations =
      updated_tiles |> Enum.reduce(relations, fn t, acc -> Map.put(acc, t.id, t) end)

    orient_tiles(updated_tiles ++ rest, updated_relations)
  end

  def connect_neighbour(tile, {dir, edge}, n_tile) do
    n_pos = coordinate_from_tile_in_direction(tile, dir)

    {{n_dir, n_edge}, _} =
      n_tile.neighbours
      |> Enum.find(fn {_, id} -> tile.id == id end)

    tile_dir = Edge.opposite(dir)

    operations = Edge.ops({n_dir, n_edge}, {tile_dir, edge})

    new_edges = n_tile.edges |> Enum.map(fn e -> Edge.apply_ops(operations, e) end)

    new_neighbours =
      n_tile.neighbours |> Enum.map(fn {e, nid} -> {Edge.apply_ops(operations, e), nid} end)

    new_matrix = Matrix.apply_ops(operations, n_tile.matrix)

    %{
      n_tile
      | pos: n_pos,
        neighbours: new_neighbours,
        operations: operations,
        matrix: new_matrix,
        edges: new_edges
    }

    # Figure how to get n_tiles tile.id-edge to n_edge and align with edge
  end

  def is_corner?(tile), do: Enum.count(tile.neighbours) == 2

  def coordinate_from_tile_in_direction(%{pos: {x, y}}, dir) do
    case dir do
      :bottom -> {x, y - 1}
      :top -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def matching_edges(edges, rest) do
    for edge <- edges,
        tile <- rest,
        tile_matching_edge?(tile, edge),
        do: {edge, tile}
  end

  def tile_matching_edge?(%{edges: edges}, {_, edge}) do
    match_against = [edge, String.reverse(edge)]

    not (edges
         |> Enum.filter(fn {_, e} -> e in match_against end)
         |> Enum.empty?())
  end
end

defmodule AdventOfCode.Day20.V1.Parser do
  def parse(file) do
    AdventOfCode.Helpers.Data.read_from_file_no_split(file)
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_tile/1)
  end

  def parse_tile(data) do
    [id_string | matrix_data] =
      data
      |> String.split("\n", trim: true)

    id = parse_tile_id(id_string)

    %{
      id: id,
      edges: parse_matrix_edges(matrix_data),
      matrix: matrix_data,
      neighbours: [],
      pos: nil,
      operations: []
    }
  end

  def parse_tile_id(tile_id_string) do
    Regex.run(~r/^Tile\s(\d+)\:/, tile_id_string, capture: :all_but_first) |> hd
  end

  def parse_matrix_edges(data) do
    top = List.first(data)
    bottom = List.last(data)

    [left, right] =
      Enum.map(data, fn line -> {String.slice(line, 0, 1), String.slice(line, -1, 1)} end)
      |> Enum.reduce([[], []], fn {s, e}, [l, r] ->
        [[s | l], [e | r]]
      end)
      |> Enum.map(fn l -> l |> Enum.reverse() |> Enum.join() end)

    [
      {:top, top},
      {:right, right},
      {:bottom, bottom},
      {:left, left}
    ]
  end
end

defmodule AdventOfCode.Day20.V1.Edge do
  def ops(rotating, target) do
    ops(rotating, target, [])
    |> Enum.reverse()
  end

  def ops({r_dir, r_str}, {t_dir, t_str}, ops) when r_dir == t_dir do
    if r_str == t_str do
      ops
    else
      case r_dir do
        :top -> [:hflip | ops]
        :bottom -> [:hflip | ops]
        :left -> [:vflip | ops]
        :right -> [:vflip | ops]
      end
    end
  end

  def ops(rotating, target, ops) do
    new_rotating = rotate90(rotating)

    ops(new_rotating, target, [:rotate90 | ops])
  end

  def apply_ops([], edge), do: edge

  def apply_ops([h | r], edge) do
    new_edge =
      case h do
        :vflip -> vflip(edge)
        :hflip -> hflip(edge)
        :rotate90 -> rotate90(edge)
      end

    apply_ops(r, new_edge)
  end

  def vflip({dir, str}) do
    case dir do
      :top -> {:bottom, str}
      :left -> {:left, String.reverse(str)}
      :bottom -> {:top, str}
      :right -> {:right, String.reverse(str)}
    end
  end

  def hflip({dir, str}) do
    case dir do
      :left -> {:right, str}
      :top -> {:top, String.reverse(str)}
      :right -> {:left, str}
      :bottom -> {:bottom, String.reverse(str)}
    end
  end

  def rotate90({dir, str}) do
    case dir do
      :left -> {:top, String.reverse(str)}
      :top -> {:right, str}
      :right -> {:bottom, String.reverse(str)}
      :bottom -> {:left, str}
    end
  end

  def opposite(dir) do
    case dir do
      :top -> :bottom
      :bottom -> :top
      :left -> :right
      :right -> :left
    end
  end
end

defmodule AdventOfCode.Day20.V1.Matrix do
  def apply_ops([], matrix), do: matrix

  def apply_ops([h | r], matrix) do
    new_matrix = apply_op(matrix, h)

    apply_ops(r, new_matrix)
  end

  def apply_op(rows, :rotate90) do
    rotate(rows)
  end

  def apply_op(rows, :hflip) do
    rows
    |> Enum.map(&String.reverse/1)
  end

  def apply_op(rows, :vflip) do
    rows
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
    IO.puts("--------")

    matrix
  end
end
