defmodule Exercise do
  def run(list, acc \\ MapSet.new())
  def run([_ | []], acc), do: Enum.count(acc)

  def run([h | t], acc) do
    run(t, overlap(h, t, acc))
  end

  def overlap(_r1, [], acc), do: acc

  def overlap(r1, [r2 | rest], acc) do
    left = rectangle_definition(r1)
    right = rectangle_definition(r2)

    intersected_points =
      if intersect?(left, right) do
        left
        |> build_rectangle()
        |> intersected_points(build_rectangle(right))
        |> MapSet.union(acc)
      else
        acc
      end

    overlap(r1, rest, intersected_points)
  end

  def build_rectangle(%{"x" => x, "y" => y, "w" => w, "h" => h}) do
    for x1 <- x..(x + w), y1 <- y..(y + h), do: {x1, y1}
  end

  defp rectangle_definition(line) do
    %{"x" => x, "y" => y, "w" => w, "h" => h} =
      Regex.named_captures(~r/^#\d+\s\@\s(?<x>\d+),(?<y>\d+):\s(?<w>\d+)x(?<h>\d+)/, line)

    %{
      "x" => String.to_integer(x) + 1,
      "y" => String.to_integer(y) + 1,
      "w" => String.to_integer(w) - 1,
      "h" => String.to_integer(h) - 1
    }
  end

  defp intersect?(%{"x" => x1, "y" => y1, "w" => w1, "h" => h1}, %{
         "x" => x2,
         "y" => y2,
         "w" => w2,
         "h" => h2
       }) do
    not (x1 + w1 < x2 or x2 + w2 < x1 or y1 + h1 < y2 or y2 + h2 < y1)
  end

  defp intersected_points(r1, r2) do
    r1 |> MapSet.new() |> MapSet.intersection(MapSet.new(r2))
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
