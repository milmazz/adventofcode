Code.require_file("repose.exs")

ExUnit.start()

defmodule ReposeTest do
  use ExUnit.Case

  import Repose

  test "should apply first strategy" do
    input = """
    [1518-11-01 00:00] Guard #10 begins shift
    [1518-11-01 00:05] falls asleep
    [1518-11-01 00:25] wakes up
    [1518-11-01 00:30] falls asleep
    [1518-11-01 00:55] wakes up
    [1518-11-01 23:58] Guard #99 begins shift
    [1518-11-02 00:40] falls asleep
    [1518-11-02 00:50] wakes up
    [1518-11-03 00:05] Guard #10 begins shift
    [1518-11-03 00:24] falls asleep
    [1518-11-03 00:29] wakes up
    [1518-11-04 00:02] Guard #99 begins shift
    [1518-11-04 00:36] falls asleep
    [1518-11-04 00:46] wakes up
    [1518-11-05 00:03] Guard #99 begins shift
    [1518-11-05 00:45] falls asleep
    [1518-11-05 00:55] wakes up
    """

    assert input |> String.split("\n", trim: true) |> first_strategy() == 240
  end

  test "should apply second strategy" do
    input = """
    [1518-11-01 00:00] Guard #10 begins shift
    [1518-11-01 00:05] falls asleep
    [1518-11-01 00:25] wakes up
    [1518-11-01 00:30] falls asleep
    [1518-11-01 00:55] wakes up
    [1518-11-01 23:58] Guard #99 begins shift
    [1518-11-02 00:40] falls asleep
    [1518-11-02 00:50] wakes up
    [1518-11-03 00:05] Guard #10 begins shift
    [1518-11-03 00:24] falls asleep
    [1518-11-03 00:29] wakes up
    [1518-11-04 00:02] Guard #99 begins shift
    [1518-11-04 00:36] falls asleep
    [1518-11-04 00:46] wakes up
    [1518-11-05 00:03] Guard #99 begins shift
    [1518-11-05 00:45] falls asleep
    [1518-11-05 00:55] wakes up
    """

    assert input |> String.split("\n", trim: true) |> second_strategy() == 4455
  end

  test "should sort repose records" do
    expected = [
      {~N[1518-11-01 00:00:00], "Guard #10 begins shift"},
      {~N[1518-11-01 00:05:00], "falls asleep"},
      {~N[1518-11-01 00:25:00], "wakes up"},
      {~N[1518-11-01 00:30:00], "falls asleep"},
      {~N[1518-11-01 00:55:00], "wakes up"},
      {~N[1518-11-01 23:58:00], "Guard #99 begins shift"},
      {~N[1518-11-02 00:40:00], "falls asleep"},
      {~N[1518-11-02 00:50:00], "wakes up"},
      {~N[1518-11-03 00:05:00], "Guard #10 begins shift"},
      {~N[1518-11-03 00:24:00], "falls asleep"},
      {~N[1518-11-03 00:29:00], "wakes up"},
      {~N[1518-11-04 00:02:00], "Guard #99 begins shift"},
      {~N[1518-11-04 00:36:00], "falls asleep"},
      {~N[1518-11-04 00:46:00], "wakes up"},
      {~N[1518-11-05 00:03:00], "Guard #99 begins shift"},
      {~N[1518-11-05 00:45:00], "falls asleep"},
      {~N[1518-11-05 00:55:00], "wakes up"}
    ]

    input = [
      "[1518-11-01 00:25] wakes up",
      "[1518-11-02 00:50] wakes up",
      "[1518-11-05 00:55] wakes up",
      "[1518-11-05 00:45] falls asleep",
      "[1518-11-03 00:24] falls asleep",
      "[1518-11-03 00:29] wakes up",
      "[1518-11-04 00:46] wakes up",
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-01 00:30] falls asleep",
      "[1518-11-04 00:02] Guard #99 begins shift",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-01 00:05] falls asleep",
      "[1518-11-01 00:00] Guard #10 begins shift",
      "[1518-11-04 00:36] falls asleep",
      "[1518-11-05 00:03] Guard #99 begins shift",
      "[1518-11-03 00:05] Guard #10 begins shift",
      "[1518-11-01 00:55] wakes up"
    ]

    assert sort_records(input) == expected
  end

  test "should parse a record" do
    record = {~N[1518-11-01 00:00:00], "Guard #10 begins shift"}
    acc = {%{}, nil}
    assert parse_records(record, acc) == {%{}, 10}

    acc1 = {%{10 => %{5 => 1, "total" => 1}}, 10}
    assert parse_records(record, acc1) == acc1

    record = {~N[1518-11-01 00:05:00], "falls asleep"}
    acc2 = {%{10 => %{5 => 1, "total" => 1, "falls_asleep" => 5}}, 10}
    assert parse_records(record, acc1) == acc2

    record = {~N[1518-11-01 00:25:00], "wakes up"}

    acc3 =
      {%{
         10 => %{
           5 => 2,
           "falls_asleep" => 5,
           6 => 1,
           7 => 1,
           8 => 1,
           9 => 1,
           10 => 1,
           11 => 1,
           12 => 1,
           13 => 1,
           14 => 1,
           15 => 1,
           16 => 1,
           17 => 1,
           18 => 1,
           19 => 1,
           20 => 1,
           21 => 1,
           22 => 1,
           23 => 1,
           24 => 1,
           "total" => 21
         }
       }, 10}

    assert parse_records(record, acc2) == acc3
  end

  test "should find the lazy guard" do
    parsed_records = %{10 => %{"total" => 10}, 15 => %{"total" => 5}, 20 => %{"total" => 20}}
    assert sleepy_guard(parsed_records) == {20, %{"total" => 20}}
  end

  test "should find lazy minute" do
    guard_info = %{1 => 2, 2 => 3, 5 => 1, 20 => 25, 30 => 1}
    assert lazy_minute(guard_info) == {20, 25}
  end
end
