defmodule AdventOfCode.Day14 do
  @bits 36

  def test_data() do
    """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """
    |> String.split("\n", trim: true)
  end

  def test_data2() do
    """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """
    |> String.split("\n", trim: true)
  end

  def run() do
    AdventOfCode.Helpers.Data.read_from_file("day14.txt")
    |> Enum.map(&parse_row/1)
    |> run_machine()
    |> sum_result()
  end

  def run2() do
    AdventOfCode.Helpers.Data.read_from_file("day14.txt")
    # test_data2()
    |> Enum.map(&parse_row/1)
    |> run_machine2()
    |> sum_result()
  end

  def sum_result({_, registers}) do
    registers
    |> Enum.map(fn {_, binary} -> String.to_integer(binary, 2) end)
    |> Enum.reduce(&(&1 + &2))
  end

  def parse_row("mask = " <> mask), do: {:mask, mask}

  def parse_row("mem[" <> rest) do
    [address, value] =
      Regex.run(~r/^(\d+)\] = (\d+)$/, rest, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    {:mem, address, value}
  end

  def parse_number(nr) do
    nr
    |> String.to_integer()
    |> dec_to_binary(@bits)
  end

  def dec_to_binary(number, bits) do
    number
    |> Integer.to_string(2)
    |> String.pad_leading(bits, "0")
  end

  def run_machine(input) do
    input
    |> Enum.reduce({String.pad_leading("", @bits, "X"), %{}}, &run_instruction/2)
  end

  def run_instruction({:mask, mask}, {_, registers}), do: {mask, registers}

  def run_instruction({:mem, address, value}, {mask, registers}) do
    new_value = set(mask, dec_to_binary(value, @bits))

    {mask, Map.put(registers, address, new_value)}
  end

  def set(mask, value) do
    p = fn s -> s |> String.graphemes() |> Enum.reverse() end
    set(p.(mask), p.(value), [])
  end

  def set([], [], new), do: new |> Enum.join()

  def set([m | m_tail], [v | v_tail], new) do
    bit = if m == "X", do: v, else: m
    set(m_tail, v_tail, [bit | new])
  end

  # Part 2
  def run_machine2(input) do
    input
    |> Enum.reduce({String.pad_leading("", @bits, "X"), %{}}, &run_instruction2/2)
  end

  def run_instruction2({:mask, mask}, {_, registers}), do: {mask, registers}

  def run_instruction2({:mem, address, value}, {mask, registers}) do
    registers =
      address(mask, dec_to_binary(address, @bits))
      |> generate_addresses()
      |> Enum.map(fn x -> String.to_integer(x, 2) end)
      |> Enum.reduce(registers, fn address, registers ->
        Map.put(registers, address, dec_to_binary(value, @bits))
      end)

    {mask, registers}
  end

  def unfloat_address(address) when is_binary(address) do
    address
    |> String.graphemes()
    |> Enum.reverse()
    |> unfloat_address([])
  end

  def unfloat_address([], address), do: [address |> Enum.join()]

  def unfloat_address([h | t], address) do
    case h do
      "X" ->
        Enum.concat(unfloat_address(t, ["1" | address]), unfloat_address(t, ["0" | address]))

      _ ->
        unfloat_address(t, [h | address])
    end
  end

  def generate_addresses(address), do: unfloat_address(address)

  def address(mask, address) do
    p = fn s -> s |> String.graphemes() |> Enum.reverse() end
    address(p.(mask), p.(address), [])
  end

  def address([], [], address), do: Enum.join(address)

  def address([m | m_tail], [a | a_tail], address) do
    bit =
      case m do
        "0" -> a
        _ -> m
      end

    address(m_tail, a_tail, [bit | address])
  end
end
