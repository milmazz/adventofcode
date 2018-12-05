defmodule Exercise do
  # overlapped square inches is the first part of the exercise
  def overlap(list, acc \\ %{})

  def overlap([], acc), do: Enum.reduce(acc, 0, &process_overlap_result/2)

  def overlap([h | t], acc), do: overlap(t, claimed(h, acc))

  # non-overlapped claims is the second part of the exercise
  def non_overlap(list, acc \\ %{})

  def non_overlap([], acc) do
    base = %{overlaps: MapSet.new(), non_overlaps: MapSet.new()}

    acc
    |> Enum.reduce(base, &process_non_overlap_result/2)
    |> process_non_overlap_map()
  end

  def non_overlap([h | t], acc), do: non_overlap(t, claimed(h, acc))

  defp claimed(claim, acc) do
    claim
    |> rectangle_definition()
    |> build_rectangle()
    |> Enum.reduce(acc, fn {x, y, claim}, acc ->
      Map.update(acc, {x, y}, [claim], &[claim | &1])
    end)
  end

  defp build_rectangle(%{"x" => x, "y" => y, "w" => w, "h" => h, "claim" => claim}) do
    for x <- (x + 1)..(x + w), y <- (y + 1)..(y + h), do: {x, y, claim}
  end

  defp rectangle_definition(line) do
    for {k, v} <-
          Regex.named_captures(
            ~r/^#(?<claim>\d+)\s\@\s(?<x>\d+),(?<y>\d+):\s(?<w>\d+)x(?<h>\d+)/,
            line
          ),
        into: %{},
        do: {k, String.to_integer(v)}
  end

  defp process_overlap_result({_point, [_ | [_ | _]]}, acc), do: acc + 1
  defp process_overlap_result(_, acc), do: acc

  defp process_non_overlap_result({_point, [claim]}, %{non_overlaps: non_overlaps} = acc) do
    %{acc | non_overlaps: MapSet.put(non_overlaps, claim)}
  end

  defp process_non_overlap_result({_, claims}, %{overlaps: overlaps} = acc) do
    %{acc | overlaps: Enum.reduce(claims, overlaps, fn claim, acc -> MapSet.put(acc, claim) end)}
  end

  defp process_non_overlap_map(%{overlaps: overlaps, non_overlaps: non_overlaps}) do
    MapSet.difference(non_overlaps, overlaps)
  end

  def read_file do
    "input"
    |> File.stream!()
    |> Stream.map(fn line ->
      line |> String.trim()
    end)
    |> Enum.to_list()
  end
end
