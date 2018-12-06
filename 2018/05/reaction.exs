defmodule Reaction do
  # elixir -r reaction.exs -e "Reaction.first_part() |> IO.puts()"
  def first_part do
    read_file()
    |> reduce()
    |> String.length()
  end

  # elixir -r reaction.exs -e "Reaction.second_part() |> IO.puts()"
  def second_part do
    {_unit, number} =
      read_file()
      |> String.to_charlist()
      |> shortest_polymer()

    number
  end

  @doc """
  Calculates polymer reactions.
  """
  def reduce(word, acc \\ "")

  def reduce(word, acc) when word == acc, do: word

  def reduce(word, _acc), do: reduce(seek_and_destroy(word), word)

  @doc """
  Destroy two adjacent units of the same type and opposite polarity.
  """
  def seek_and_destroy(binary, acc \\ [])

  for lowercase <- ?a..?z do
    uppercase = lowercase - 32

    def seek_and_destroy(<<unquote(lowercase), unquote(uppercase), rest::binary>>, acc),
      do: seek_and_destroy(rest, acc)

    def seek_and_destroy(<<unquote(uppercase), unquote(lowercase), rest::binary>>, acc),
      do: seek_and_destroy(rest, acc)
  end

  def seek_and_destroy(<<header, rest::binary>>, acc),
    do: seek_and_destroy(rest, [header | acc])

  def seek_and_destroy("", acc),
    do: acc |> Enum.reverse() |> to_string()

  # Shortest polymer
  def shortest_polymer(input) do
    Enum.reduce(?a..?z, {nil, :infinity}, fn unit, acc ->
      current =
        input
        |> Enum.reduce([], fn letter, acc ->
          remove_unit(unit, letter, acc)
        end)
        |> Enum.reverse()
        |> to_string()
        |> reduce()
        |> String.length()

      compare_polymers(acc, {unit, current})
    end)
  end

  # Compare polymer chain length
  def compare_polymers({_, old_num}, {new, num}) when old_num > num, do: {new, num}
  def compare_polymers(old, _), do: old

  # Remove the letter from the list based on the unit
  def remove_unit(unit, letter, list) do
    if letter == unit or letter == unit - 32 do
      list
    else
      [letter | list]
    end
  end

  # Helper to read the input file
  defp read_file do
    "input"
    |> File.read!()
    |> String.trim()
  end
end
