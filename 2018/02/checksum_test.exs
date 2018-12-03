Code.require_file("checksum.exs")

ExUnit.start()

defmodule ChecksumTest do
  use ExUnit.Case

  import Checksum

  test "calculates Box IDs checksum" do
    assert run(['abcdef', 'bababc', 'abbcde', 'abcccd', 'aabcdd', 'abcdee', 'ababab']) == 12
  end
end
