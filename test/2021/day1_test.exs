defmodule AdventOfCodeTest.Day1 do
  use ExUnit.Case

  alias AdventOfCode.Y2021.Day1

  test "test_part1" do
    result = Day1.run1(Day1.test_data())

    assert result == 7
  end

  test "test_part2" do
    result = Day1.run2(Day1.test_data())

    assert result == 5
  end
end
