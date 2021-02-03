defmodule AdventOfCode.Day21 do
  def run() do
    parsed =
      AdventOfCode.Helpers.Data.read_from_file_no_split("day21.txt")
      |> parse()

    {solve1(parsed), solve2(parsed)}
  end

  def solve1(parsed) do
    safe_ingredients = allergen_free(parsed)

    parsed
    |> Stream.flat_map(fn {_, ingredients} -> ingredients end)
    |> Stream.filter(&MapSet.member?(safe_ingredients, &1))
    |> Enum.count()
  end

  def solve2(parsed) do
    parsed
    |> allergen_to_possible_ingredients()
    |> allergens_to_certain_ingredient()
    |> Enum.sort(fn a, b -> elem(a, 0) < elem(b, 0) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  def allergen_free(parsed) do
    all_ingredients =
      parsed |> Enum.reduce(MapSet.new(), fn {_, i}, acc -> MapSet.union(i, acc) end)

    parsed
    |> allergen_to_possible_ingredients()
    |> Enum.reduce(all_ingredients, fn {_, ingredients}, acc ->
      MapSet.difference(acc, ingredients)
    end)
  end

  def dish_to_allergen_map({allergens, ingredients}) do
    allergens
    |> Enum.map(fn allergen -> {allergen, ingredients} end)
    |> Map.new()
  end

  def allergen_to_possible_ingredients(lines) do
    lines
    |> Enum.map(&dish_to_allergen_map/1)
    |> Enum.reduce(fn map, acc ->
      Map.merge(map, acc, fn _, v1, v2 -> MapSet.intersection(v1, v2) end)
    end)
  end

  def allergens_to_certain_ingredient(unmapped) do
    {[], Enum.to_list(unmapped)}
    |> Stream.iterate(&extract_allergen_matches/1)
    |> Stream.take_while(&more_allergens_to_process?/1)
    |> Stream.drop(1)
    |> Stream.flat_map(fn {matches, _} ->
      matches |> Enum.map(fn {k, v} -> {k, Enum.take(v, 1) |> hd} end)
    end)
    |> Map.new()
  end

  def more_allergens_to_process?(progress) do
    progress
    |> Tuple.to_list()
    |> Enum.all?(&Enum.empty?/1)
    |> Kernel.not()
  end

  def extract_allergen_matches({last_matches, unprocessed}) do
    matches =
      last_matches |> Enum.reduce(MapSet.new(), fn {_, v}, acc -> MapSet.union(acc, v) end)

    unprocessed
    |> Enum.map(fn {key, ingredients} -> {key, MapSet.difference(ingredients, matches)} end)
    |> Enum.split_with(fn {_, ingredients} -> MapSet.size(ingredients) == 1 end)
  end

  def parse(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.replace(~r/[\(\),]/, "")
    |> String.split("contains", trim: true)
    |> Enum.map(&String.split/1)
    |> (fn [ingredients, allergens] -> {allergens, MapSet.new(ingredients)} end).()
  end
end
