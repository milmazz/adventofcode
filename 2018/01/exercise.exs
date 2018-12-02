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

  @spec frequency([integer]) :: integer
  def frequency(freq_changes) do
    Enum.sum(freq_changes)
  end

  @spec first_frequency_reached_twice([integer], {integer, MapSet.t()} | integer) :: integer
  def first_frequency_reached_twice(frequency_changes, acc \\ {0, MapSet.new([0])})

  def first_frequency_reached_twice(_, acc) when is_integer(acc), do: acc

  def first_frequency_reached_twice(frequency_changes, acc) do
    result =
      Enum.reduce_while(frequency_changes, acc, fn digit, {current, past} ->
        next = current + digit

        if MapSet.member?(past, next) do
          {:halt, next}
        else
          {:cont, {next, MapSet.put(past, next)}}
        end
      end)

    first_frequency_reached_twice(frequency_changes, result)
  end

  defp process_file do
    "input"
    |> File.stream!()
    |> Stream.map(fn x ->
      x |> String.trim() |> String.to_integer()
    end)
    |> Enum.to_list()
  end
end

ExUnit.start()

defmodule FrequencyTest do
  use ExUnit.Case

  import Frequency

  test "should calculate frequency" do
    test_cases = [
      {[1, -2, 3, 1], 3},
      {[1, 1, 1], 3},
      {[1, 1, -2], 0},
      {[-1, -2, -3], -6}
    ]

    Enum.each(test_cases, fn {changes, expected} ->
      assert frequency(changes) == expected
    end)
  end

  test "should stop when a frequency is reached twice" do
    test_cases = [
      {[1, -2, 3, 1, 1, -2], 2},
      {[1, -1], 0},
      {[3, 3, 4, -2, -4], 10},
      {[-6, 3, 8, 5, -6], 5},
      {[7, 7, -2, -7, -4], 14}
    ]

    Enum.each(test_cases, fn {changes, expected} ->
      assert first_frequency_reached_twice(changes) == expected
    end)
  end
end
