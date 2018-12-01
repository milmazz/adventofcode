# https://adventofcode.com/2018/day/1
#
# To run each exercise, you can do the following:
#
# elixir -r exercise.exs -e "IO.inspect(Frequency.first_exercise())"
# elixir -r exercise.exs -e "IO.inspect(Frequency.second_exercise())"
#
defmodule Frequency do
  def first_exercise, do: frequency(process_file())

  def second_exercise, do: first_frequency_reached_twice(process_file())

  @spec frequency(String.t()) :: integer
  def frequency(freq_changes) do
    freq_changes
    |> String.split(", ")
    |> Enum.reduce(0, fn digit, acc ->
      acc + String.to_integer(digit)
    end)
  end

  @spec first_frequency_reached_twice(String.t()) :: integer
  def first_frequency_reached_twice(freq_changes) do
    freq_changes
    |> String.split(", ")
    |> find_frequency({0, MapSet.new([0])})
  end

  ## Helpers
  defp find_frequency(_, acc) when is_integer(acc), do: acc

  defp find_frequency(frequency_changes, acc) do
    result =
      Enum.reduce_while(frequency_changes, acc, fn digit, {current, past} ->
        next = current + String.to_integer(digit)

        if MapSet.member?(past, next) do
          {:halt, next}
        else
          {:cont, {next, MapSet.put(past, next)}}
        end
      end)

    find_frequency(frequency_changes, result)
  end

  defp process_file do
    "input"
    |> File.read!()
    |> String.split()
    |> Enum.join(", ")
  end
end

ExUnit.start()

defmodule FrequencyTest do
  use ExUnit.Case

  import Frequency

  test "should calculate frequency" do
    assert frequency("+1, -2, +3, +1") == 3
    assert frequency("+1, +1, +1") == 3
    assert frequency("+1, +1, -2") == 0
    assert frequency("-1, -2, -3") == -6
  end

  test "should stop when a frequency is reached twice" do
    test_cases = [
      {"+1, -2, +3, +1, +1, -2", 2},
      {"+1, -1", 0},
      {"+3, +3, +4, -2, -4", 10},
      {"-6, +3, +8, +5, -6", 5},
      {"+7, +7, -2, -7, -4", 14}
    ]

    Enum.each(test_cases, fn {changes, result} ->
      assert first_frequency_reached_twice(changes) == result
    end)
  end
end
