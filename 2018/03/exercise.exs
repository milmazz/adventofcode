defmodule Exercise do
  def overlap(list, acc \\ %{})

  def overlap([], acc) do
    Enum.reduce(acc, 0, &process_result/2)
  end

  def overlap([h | t], acc) do
    overlap(t, claimed(h, acc))
  end

  defp claimed(claim, acc) do
    claim
    |> rectangle_definition()
    |> build_rectangle()
    |> Enum.reduce(acc, fn point, acc ->
      Map.update(acc, point, 1, &(&1 + 1))
    end)
  end

  defp build_rectangle(%{"x" => x, "y" => y, "w" => w, "h" => h}) do
    for x1 <- (x + 1)..(x + w), y1 <- (y + 1)..(y + h), do: {x1, y1}
  end

  defp rectangle_definition(line) do
    for {k, v} <-
          Regex.named_captures(~r/^#\d+\s\@\s(?<x>\d+),(?<y>\d+):\s(?<w>\d+)x(?<h>\d+)/, line),
        into: %{},
        do: {k, String.to_integer(v)}
  end

  defp process_result({_point, claims}, acc) when claims > 1, do: acc + 1
  defp process_result(_, acc), do: acc

  def read_file do
    "input"
    |> File.stream!()
    |> Stream.map(fn line ->
      line |> String.trim()
    end)
    |> Enum.to_list()
  end
end
