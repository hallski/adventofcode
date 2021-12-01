defmodule AdventOfCode.Y2020.Day22 do
  alias AdventOfCode.Y2020.Day22.Rules

  def run_game(game) do
    AdventOfCode.Helpers.Data.read_from_file_no_split("2020/day22.txt")
    |> parse()
    |> game.()
    |> score()
  end

  def run1(), do: run_game(&Rules.Normal.play/1)
  def run2(), do: run_game(&Rules.Recursive.play/1)

  def parse(data) do
    data
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn lines ->
      lines
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def score({_player, deck}) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {card, score}, acc -> card * score + acc end)
  end
end

defmodule AdventOfCode.Y2020.Day22.Rules.Normal do
  def play([one, two]), do: play(one, two)

  def play([_ | _] = winning_hand, []), do: {:one, winning_hand}
  def play([], [_ | _] = winning_hand), do: {:two, winning_hand}

  def play([a_head | a_rest], [b_head | b_rest]) when a_head > b_head do
    play(a_rest ++ [a_head, b_head], b_rest)
  end

  def play([a_head | a_rest], [b_head | b_rest]) do
    play(a_rest, b_rest ++ [b_head, a_head])
  end
end

defmodule AdventOfCode.Y2020.Day22.Rules.Recursive do
  def play([one, two]), do: play(one, two, MapSet.new())

  def play([_ | _] = winning_hand, [], _history), do: {:one, winning_hand}
  def play([], [_ | _] = winning_hand, _history), do: {:two, winning_hand}

  def play(a_hand, b_hand, history) do
    cond do
      seen_before?(a_hand, b_hand, history) -> {:one, a_hand}
      can_play_subgame?(a_hand, b_hand) -> play_subgame(a_hand, b_hand, history)
      true -> play_normal_round(a_hand, b_hand, history)
    end
  end

  def next_round(winner, [a_card | a_rest] = a_hand, [b_card | b_rest] = b_hand, history) do
    next_history = MapSet.put(history, [a_hand, b_hand])

    case winner do
      :one -> play(a_rest ++ [a_card, b_card], b_rest, next_history)
      :two -> play(a_rest, b_rest ++ [b_card, a_card], next_history)
    end
  end

  def play_normal_round([a_card | _] = a_hand, [b_card | _] = b_hand, history) do
    winner = if a_card > b_card, do: :one, else: :two
    next_round(winner, a_hand, b_hand, history)
  end

  def play_subgame([a_card | a_rest] = a_hand, [b_card | b_rest] = b_hand, history) do
    a_sub_hand = a_rest |> Enum.take(a_card)
    b_sub_hand = b_rest |> Enum.take(b_card)

    {winner, _} = play([a_sub_hand, b_sub_hand])
    next_round(winner, a_hand, b_hand, history)
  end

  def can_play_subgame?([a_card | a_rest], [b_card | b_rest]) do
    a_card <= length(a_rest) and b_card <= length(b_rest)
  end

  def seen_before?(a_hand, b_hand, history), do: MapSet.member?(history, [a_hand, b_hand])
end
