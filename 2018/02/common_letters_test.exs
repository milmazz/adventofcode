Code.require_file("common_letters.exs")

ExUnit.start()

defmodule ChecksumTest do
  use ExUnit.Case

  import CommonLetters

  test "find common_letters" do
    assert run(['abcde', 'fghij', 'klmno', 'pqrst', 'fguij', 'axcye', 'wvxyz']) == 'fgij'
  end
end
