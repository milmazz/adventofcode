Code.require_file("exercise.exs")

ExUnit.start()

defmodule ExerciseTest do
  use ExUnit.Case

  import Exercise

  test "should find the square inches" do
    assert overlap(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 4
  end
end
