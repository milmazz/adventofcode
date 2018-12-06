defmodule Reaction do
  # elixir -r reaction.exs -e "Reaction.first_part() |> IO.puts()"
  def first_part do
    read_file()
    |> reduce()
    |> String.length()
  end

  # elixir -r reaction.exs -e "Reaction.second_part() |> IO.puts()"
  def second_part do
    {_unit, number} = shortest_polymer(read_file())

    number
  end

  @doc """
  Calculates polymer reactions.
  """
  def reduce(word, acc \\ "")

  def reduce(word, acc) when word == acc, do: word

  def reduce(word, _acc), do: word |> seek_and_destroy() |> reduce(word)

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
    ?a..?z
    |> Enum.reduce([], fn unit, acc ->
      [
        Task.async(fn ->
          length =
            input
            |> remove_unit(unit)
            |> reduce()
            |> String.length()

          {unit, length}
        end)
        | acc
      ]
    end)
    |> Enum.map(fn task -> Task.await(task, 10_000) end)
    |> Enum.min_by(fn {_unit, value} -> value end)
  end

  # Compare polymer chain length
  def compare_polymers({_, old_num}, {new, num}) when old_num > num, do: {new, num}
  def compare_polymers(old, _), do: old

  # Remove the letter from the list based on the unit
  def remove_unit(binary, letter, acc \\ [])

  for lowercase <- ?a..?z do
    uppercase = lowercase - 32

    def remove_unit(<<unquote(lowercase), rest::binary>>, unquote(lowercase), acc),
      do: remove_unit(rest, unquote(lowercase), acc)

    def remove_unit(<<unquote(uppercase), rest::binary>>, unquote(lowercase), acc),
      do: remove_unit(rest, unquote(lowercase), acc)
  end

  def remove_unit(<<header, rest::binary>>, letter, acc),
    do: remove_unit(rest, letter, [header | acc])

  def remove_unit("", _, acc),
    do: acc |> Enum.reverse() |> to_string()

  # Helper to read the input file
  defp read_file do
    "input"
    |> File.read!()
    |> String.trim()
  end
end
