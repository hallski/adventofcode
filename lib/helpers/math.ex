defmodule AdventOfCode.Helpers.Math do
  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end
end
