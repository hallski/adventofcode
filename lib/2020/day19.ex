defmodule AdventOfCode.Day19 do
  import ExProf.Macro

  alias AdventOfCode.Day19.Parser

  def run1() do
    AdventOfCode.Helpers.Data.read_from_file_no_split("2020/day19.txt")
    |> Parser.parse()
    |> count_valid()
  end

  def run2() do
    AdventOfCode.Helpers.Data.read_from_file_no_split("2020/day19.txt")
    |> Parser.parse()
    |> patch_rules()
    |> count_valid()
  end

  def profiled_run2() do
    profile do
      run2()
    end
    |> (fn {_, res} -> res end).()
  end

  def patch_rules(%{rules: rules, messages: messages}) do
    new_rules =
      rules
      |> Map.put("8", Parser.parse_rule("42 | 42 8"))
      |> Map.put("11", Parser.parse_rule("42 31 | 42 11 31"))

    %{rules: new_rules, messages: messages}
  end

  def count_valid(%{messages: messages, rules: rules}) do
    zero = Map.get(rules, "0")

    messages
    |> Task.async_stream(fn msg -> validate(msg, zero, rules) end)
    |> Stream.filter(fn {:ok, result} -> result end)
    |> Enum.count()
  end

  def validate([], [], _rules), do: true
  def validate([], _rule, _rules), do: false
  def validate(_str, [], _rules), do: false

  def validate([first | unprocessed], [{:char, char} | rest], rules) do
    if first == char, do: validate(unprocessed, rest, rules), else: false
  end

  def validate(str, [[a, b] | rest], rules) when is_list(a) and is_list(b) do
    validate(str, [a | rest], rules) or validate(str, [b | rest], rules)
  end

  def validate(str, [next | rest], rules) when is_list(next) do
    validate(str, next ++ rest, rules)
  end

  def validate(str, [next | rest], rules) when is_binary(next) do
    rule = Map.get(rules, next)

    validate(str, [rule | rest], rules)
  end
end

defmodule AdventOfCode.Day19.Parser do
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> parse_rules_and_messages()
  end

  def parse_rules_and_messages([rules, messages]) do
    %{rules: parse_rules(rules), messages: parse_messages(messages)}
  end

  def parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule_line/1)
    |> Map.new()
  end

  def parse_rule_line(rule) do
    [number, rule_line] = String.split(rule, ":", trim: true)
    rule = parse_rule(rule_line)

    {number, rule}
  end

  def parse_rule(rule) do
    rule
    |> String.split("|", trim: true)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_case/1)
    |> Enum.to_list()
  end

  def parse_case(<<"\"", char::binary-size(1), "\"">>) do
    {:char, char}
  end

  def parse_case(list) do
    list |> String.split(" ", trim: true)
  end

  def parse_messages(messages) do
    messages
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end
