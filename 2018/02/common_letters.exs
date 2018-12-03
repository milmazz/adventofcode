defmodule CommonLetters do
  def second_part, do: read() |> run() |> IO.puts()

  def run(input) do
    2
    |> combination(input)
    |> Enum.reduce_while('', fn [h | [t]], acc ->
      case diff(h, t, {0, ''}) do
        {1, word} ->
          {:halt, Enum.reverse(word)}

        _ ->
          {:cont, acc}
      end
    end)
  end

  def diff([], _, acc), do: acc
  def diff(_, [], acc), do: acc
  def diff(_, _, {2, _} = acc), do: acc
  def diff([h | t], [h | t1], {number, word}), do: diff(t, t1, {number, [h | word]})
  def diff([_ | t], [_ | t1], {number, word}), do: diff(t, t1, {number + 1, word})

  def combination(0, _), do: [[]]
  def combination(_, []), do: []

  # TODO: Check if we can return a generator/stream
  def combination(n, [h | t]) do
    for(y <- combination(n - 1, t), do: [h | y]) ++ combination(n, t)
  end

  defp read do
    "input"
    |> File.stream!()
    |> Stream.map(fn line ->
      line |> String.trim() |> String.to_charlist()
    end)
    # TODO: Remove this to return a Stream
    |> Enum.to_list()
  end
end
