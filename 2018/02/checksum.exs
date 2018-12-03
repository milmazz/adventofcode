defmodule Checksum do
  def first_part, do: read() |> run() |> IO.puts()

  def run(input) do
    %{"2" => twos, "3" => threes} = Enum.reduce(input, %{}, &find_twos_and_threes/2)

    twos * threes
  end

  defp find_twos_and_threes(box_id, acc) do
    %{"2" => twos, "3" => threes} =
      box_id
      |> Enum.reduce(%{}, &count_letters/2)
      |> Map.values()
      |> Enum.reduce_while(%{"2" => 0, "3" => 0}, &filter_counters/2)

    acc
    |> Map.update("2", twos, &(&1 + twos))
    |> Map.update("3", threes, &(&1 + threes))
  end

  # Instead of using Enum.group_by/2 let's keep a count for each letter
  defp count_letters(letter, acc), do: Map.update(acc, letter, 1, &(&1 + 1))

  # We just need those letters that appears exactly two or three times, we
  # actually don't care about the letter.
  # Keep in mind that if we already found a letter that appears two times, we
  # don't care about other letters that appeared two times also, same condition
  # applies for three. That's why here we can apply a little optimization.
  defp filter_counters(2, %{"3" => 1} = acc), do: {:halt, Map.put(acc, "2", 1)}
  defp filter_counters(3, %{"2" => 1} = acc), do: {:halt, Map.put(acc, "3", 1)}

  defp filter_counters(value, acc) when value in [2, 3],
    do: {:cont, Map.put(acc, to_string(value), 1)}

  defp filter_counters(_value, acc), do: {:cont, acc}

  defp read do
    "input"
    |> File.stream!()
    |> Stream.map(fn line ->
      line |> String.trim() |> String.to_charlist()
    end)
  end
end
