defmodule AdventOfCode.Y2020.Day25 do
  @subject_number 7
  @magic_number 20_201_227

  def run({card_key, door_key}) do
    card_key
    |> loop_size(@subject_number)
    |> encryption_key(door_key)
  end

  def loop_size(key, subject), do: loop_size(1, key, subject, 0)

  def loop_size(value, key, _subject, loop) when key == value, do: loop

  def loop_size(value, key, subject, loop) do
    value
    |> transform(subject)
    |> loop_size(key, subject, loop + 1)
  end

  def encryption_key(loops, subject), do: encryption_key(1, subject, loops)

  def encryption_key(value, _subject, 0), do: value

  def encryption_key(value, subject, loops) do
    value
    |> transform(subject)
    |> encryption_key(subject, loops - 1)
  end

  def transform(value, subject) do
    rem(value * subject, @magic_number)
  end
end
