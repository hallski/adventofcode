defmodule AdventOfCode.Helpers.Op do
  def xor(a, b), do: (a && not b) or (b && not a)
end
