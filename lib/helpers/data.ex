defmodule AdventOfCode.Helpers.Data do
  @data_dir Path.expand("../../data", __DIR__)

  def read_from_file(file_name) do
    read_from_file_no_split(file_name)
    |> String.split("\n", trim: true)
  end

  def read_from_file_no_split(file_name) do
    @data_dir
    |> Path.join(file_name)
    |> File.read!()
  end

  def file_stream(file_name) do
    @data_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
