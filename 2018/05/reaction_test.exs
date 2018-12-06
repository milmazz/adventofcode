Code.require_file("reaction.exs")

ExUnit.start()

defmodule ReactionTest do
  use ExUnit.Case

  import Reaction

  test "should return the polymer chain" do
    assert "dabAcCaCBAcCcaDA" |> reduce() |> String.length() == 10
  end

  test "should apply some reductions" do
    assert reduce("aA") == ""
    assert reduce("abBA") == ""
    assert reduce("abAB") == "abAB"
    assert reduce("aabAAB") == "aabAAB"
    assert reduce("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
  end

  test "should find the shortest polymer" do
    assert shortest_polymer('dabAcCaCBAcCcaDA') == {?c, 4}
  end
end
