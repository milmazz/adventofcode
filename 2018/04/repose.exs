defmodule Repose do
  def repose_records(file_stream) do
    {parsed_records, _} =
      file_stream
      |> sort_records()
      |> Enum.reduce({%{}, nil}, &parse_records/2)

    {guard_id, guard_info} =
      Enum.max_by(parsed_records, fn {_k, v} ->
        v["total"] || 0
      end)

    {sleepy_minute, _number_of_times} =
      for({min, num} <- guard_info, is_integer(min), do: {min, num})
      |> Enum.max_by(fn {_min, num} -> num end)

    guard_id * sleepy_minute
  end

  defp sort_records(file_stream) do
    file_stream
    |> Stream.map(&String.split(&1, ["[", "] "], trim: true, parts: 2))
    |> Stream.map(fn [date | [log]] ->
      {NaiveDateTime.from_iso8601!("#{date}:00"), log}
    end)
    |> Enum.sort_by(fn {date, _} -> date end, fn d1, d2 ->
      NaiveDateTime.compare(d1, d2) == :lt
    end)
  end

  defp parse_records({date, log}, {acc, current_guard}) do
    cond do
      String.starts_with?(log, "Guard #") ->
        begin_shift(acc, log)

      String.starts_with?(log, "falls asleep") ->
        {put_in(acc[current_guard]["falls_asleep"], date.minute), current_guard}

      String.starts_with?(log, "wakes up") ->
        wakes_up(acc, date.minute, current_guard)
    end
  end

  defp begin_shift(acc, log) do
    [guard | _] = String.split(log, ["Guard #", " "], trim: true, parts: 2)
    guard_id = String.to_integer(guard)

    if Map.has_key?(acc, guard_id) do
      {acc, guard_id}
    else
      {Map.put(acc, guard_id, %{}), guard_id}
    end
  end

  defp wakes_up(acc, wakes_up, current_guard) do
    falls_asleep = Map.get(acc[current_guard], "falls_asleep")

    guard =
      Enum.reduce(falls_asleep..wakes_up, acc[current_guard], fn min, guard ->
        guard
        |> Map.update(min, 1, &(&1 + 1))
        |> Map.update("total", 1, &(&1 + 1))
      end)

    {Map.put(acc, current_guard, guard), current_guard}
  end

  def read_file do
    "input"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
