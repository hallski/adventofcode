defmodule AdventOfCode.Day8 do
  defstruct prg: [], acc: 0, cur: 0

  alias AdventOfCode.Day8
  alias AdventOfCode.Helpers.Data

  def create(prg), do: %Day8{prg: prg}

  def run1() do
    {:loop, machine, _} = run_machine()
    machine.acc
  end

  def run2() do
    {:loop, _, stack} = run_machine()
    {:ok, machine, _} = patch(stack)
    machine.acc
  end

  def run_machine() do
    Data.read_from_file("2020/day8.txt")
    |> Enum.map(&parse_line/1)
    |> create()
    |> progress([])
  end

  def parse_line(line) do
    [cmd, arg] = String.split(line, " ", trim: true)
    [cmd, String.to_integer(arg)]
  end

  def progress(%Day8{} = machine, stack) when machine.cur == length(machine.prg) do
    {:ok, machine, stack}
  end

  def progress(%Day8{} = machine, stack) do
    if Enum.any?(stack, fn past_machine -> past_machine.cur == machine.cur end) do
      {:loop, machine, stack}
    else
      machine
      |> get_instruction()
      |> execute(machine)
      |> progress([machine | stack])
    end
  end

  def get_instruction(%Day8{prg: prg, cur: cur}), do: Enum.at(prg, cur)

  def execute(["acc", arg], %Day8{} = machine) do
    %Day8{machine | cur: machine.cur + 1, acc: machine.acc + arg}
  end

  def execute(["jmp", arg], %Day8{} = machine) do
    %Day8{machine | cur: machine.cur + arg}
  end

  def execute(["nop", _], %Day8{} = machine) do
    %Day8{machine | cur: machine.cur + 1}
  end

  def patch_instruction(["nop", arg]), do: ["jmp", arg]
  def patch_instruction(["jmp", arg]), do: ["nop", arg]
  def patch_instruction(instruction), do: instruction

  def patch([]) do
    {:couldnt_patch}
  end

  def patch([head | tail]) do
    result =
      head
      |> get_instruction()
      |> patch_instruction()
      |> execute(head)
      |> progress(tail)

    case result do
      {:ok, machine, stack} -> {:ok, machine, stack}
      {:loop, _, _} -> patch(tail)
    end
  end
end
