defmodule AdventOfCode.Day4 do
  defstruct birth_year: nil,
            issued: nil,
            expire: nil,
            height: nil,
            hair_color: nil,
            eye_color: nil,
            pid: nil,
            country: nil

  alias AdventOfCode.Day4
  import AdventOfCode.Helpers.Data, only: [read_from_file_no_split: 1]

  def run() do
    read_from_file_no_split("2020/day4.txt")
    |> String.split("\n\n")
    |> Enum.map(&process_raw_data/1)
    |> Enum.filter(&is_valid/1)
    |> Enum.count()
  end

  def process_raw_data(data) do
    data
    |> String.split(~r{[\s\n]}, trim: true)
    |> Enum.reduce(%Day4{}, &capture_field/2)
  end

  def is_valid(%Day4{} = data)
      when is_nil(data.birth_year) or is_nil(data.issued) or is_nil(data.expire) or
             is_nil(data.height) or is_nil(data.hair_color) or is_nil(data.eye_color) or
             is_nil(data.pid) do
    false
  end

  def is_valid(%Day4{}), do: true

  def validate_number(number, low, high) do
    number = String.to_integer(number)

    if number >= low and number <= high do
      number
    else
      nil
    end
  end

  def test_field(str) do
    capture_field(str, %Day4{})
  end

  # byr (Birth Year) - four digits; at least 1920 and at most 2002.
  def capture_field("byr:" <> birth_year, %Day4{} = data) when is_binary(birth_year) do
    %Day4{data | birth_year: validate_number(birth_year, 1920, 2002)}
  end

  # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  def capture_field("iyr:" <> issued, %Day4{} = data) do
    %Day4{data | issued: validate_number(issued, 2010, 2020)}
  end

  # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  def capture_field("eyr:" <> expire, %Day4{} = data) do
    %Day4{data | expire: validate_number(expire, 2020, 2030)}
  end

  # hgt (Height) - a number followed by either cm or in:
  #     If in, the number must be at least 59 and at most 76.
  def capture_field(<<"hgt:", height::binary-size(3), "cm">>, %Day4{} = data) do
    %Day4{data | height: validate_number(height, 150, 193)}
  end

  # hgt (Height) - a number followed by either cm or in:
  #     If in, the number must be at least 59 and at most 76.
  def capture_field(<<"hgt:", height::binary-size(2), "in">>, %Day4{} = data) do
    %Day4{data | height: validate_number(height, 59, 76)}
  end

  # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  def capture_field("hcl:#" <> hair_color, %Day4{} = data) do
    if hair_color =~ ~r/[0-9a-f]{6}/ do
      %Day4{data | hair_color: hair_color}
    else
      data
    end
  end

  # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  def capture_field("ecl:" <> eye_color, %Day4{} = data) do
    if Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], eye_color) do
      %Day4{data | eye_color: eye_color}
    else
      data
    end
  end

  # pid (Passport ID) - a nine-digit number, including leading zeroes.
  def capture_field("pid:" <> pid, %Day4{} = data) do
    if pid =~ ~r/^[0-9]{9}$/ do
      %Day4{data | pid: pid}
    else
      data
    end
  end

  # cid (Country ID) - ignored, missing or not.
  def capture_field("cid:" <> country, %Day4{} = data),
    do: %Day4{data | country: country}

  def capture_field(_, %Day4{} = data), do: data
end
