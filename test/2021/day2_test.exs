defmodule AdventOfCode.Y2021.Day2Test do
  use ExUnit.Case

  alias AdventOfCode.Y2021.Day2

  test "part1" do
    assert Day2.process1(test_data()) == 150
  end

  test "part2" do
    assert Day2.process2(test_data()) == 900
  end

  test "move1 forward" do
    assert Day2.move1(%{:h => 15, :d => 0}, "forward 17") == %{:h => 32, :d => 0}
  end

  test "move1 up" do
    assert Day2.move1(%{:h => 12, :d => 10}, "up 7") == %{:h => 12, :d => 3}
  end

  test "move1 down" do
    assert Day2.move1(%{:h => 12, :d => 10}, "down 13") == %{:h => 12, :d => 23}
  end

  test "move2" do
    val = Day2.move2(%{h: 0, d: 0, aim: 0}, "forward 5")
    assert val == %{h: 5, d: 0, aim: 0}
    val = Day2.move2(val, "down 5")
    assert val == %{val | aim: 5}
    val = Day2.move2(val, "forward 8")
    assert val == %{val | h: 13, d: 40}
  end

  test "move2 forward 5" do
    assert Day2.move2(%{:h => 5, :d => 0, :aim => 0}, "forward 5") == %{
             :h => 10,
             :d => 0,
             :aim => 0
           }
  end

  test "move2 forward with an aim" do
    assert Day2.move2(%{:h => 4, :d => 0, :aim => 5}, "forward 5") == %{
             h: 9,
             d: 25,
             aim: 5
           }
  end

  test "move2 up" do
    assert Day2.move2(%{h: 10, d: 10, aim: 10}, "up 7") == %{h: 10, d: 10, aim: 3}
  end

  test "move2 down" do
    assert Day2.move2(%{h: 10, d: 10, aim: 10}, "down 13") == %{h: 10, d: 10, aim: 23}
  end

  defp test_data() do
    """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """
  end
end
