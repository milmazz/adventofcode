# https://adventofcode.com/2017/day/1
defmodule Exercise do
  def run([]), do: 0
  def run([h | _t] = list), do: p(list, {h, 0})

  defp p([head | []], {head, acc}), do: acc + head
  defp p([_ | []], {_, acc}), do: acc

  defp p([head | [head | tail]], {first, acc}),
    do: p([head | tail], {first, acc + head})

  defp p([_ | [head | tail]], acc), do: p([head | tail], acc)
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  import Exercise

  test "should pass captcha" do
    assert run([1, 1, 2, 2]) == 3
    assert run([1, 1, 1, 1]) == 4
    assert run([1, 2, 3, 4]) == 0
    assert run([9, 1, 2, 1, 2, 1, 2, 9]) == 9
    assert run([2]) == 2
    assert run([]) == 0
    assert run([1, 2, 1]) == 1
    assert run([1, 1]) == 2
  end
end
