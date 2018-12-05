defmodule Repose do
  def first_strategy(file_stream) do
    parsed_records = process_records(file_stream)

    {guard_id, guard_info} = sleepy_guard(parsed_records)

    {sleepy_minute, _number_of_times} = lazy_minute(guard_info)

    guard_id * sleepy_minute
  end

  def second_strategy(file_stream) do
    parsed_records = process_records(file_stream)

    {id, min, _num} =
      Enum.reduce(parsed_records, {nil, nil, 0}, fn {guard_id, guard_info}, {_, _, num} = acc ->
        {sleepy_minute, number_of_times} = lazy_minute(guard_info)

        if number_of_times > num, do: {guard_id, sleepy_minute, number_of_times}, else: acc
      end)

    id * min
  end

  def sleepy_guard(parsed_records) do
    Enum.max_by(parsed_records, fn {_k, v} -> v["total"] || 0 end)
  end

  def lazy_minute(guard_info) do
    for({min, num} <- guard_info, is_integer(min), do: {min, num})
    |> Enum.max_by(fn {_min, num} -> num end)
  end

  def process_records(file_stream) do
    {parsed_records, _} =
      file_stream
      |> sort_records()
      |> Enum.reduce({%{}, nil}, &parse_records/2)

    parsed_records
  end

  @doc """
  Sort repose records by date time
  """
  def sort_records(file_stream) do
    file_stream
    |> Stream.map(&String.split(&1, ["[", "] "], trim: true, parts: 2))
    |> Stream.map(fn [date | [log]] ->
      {NaiveDateTime.from_iso8601!("#{date}:00"), log}
    end)
    |> Enum.sort_by(fn {date, _} -> date end, fn d1, d2 ->
      NaiveDateTime.compare(d1, d2) == :lt
    end)
  end

  def parse_records({date, log}, {acc, current_guard}) do
    cond do
      String.starts_with?(log, "Guard #") ->
        begin_shift(acc, log)

      String.starts_with?(log, "falls asleep") ->
        falls_asleep(acc, current_guard, date)

      String.starts_with?(log, "wakes up") ->
        wakes_up(acc, date.minute, current_guard)
    end
  end

  defp begin_shift(acc, log) do
    [guard | _] = String.split(log, ["Guard #", " "], trim: true, parts: 2)
    guard_id = String.to_integer(guard)

    {acc, guard_id}
  end

  defp falls_asleep(acc, current_guard, date) do
    if Map.has_key?(acc, current_guard) do
      {put_in(acc[current_guard]["falls_asleep"], date.minute), current_guard}
    else
      {Map.put(acc, current_guard, %{"falls_asleep" => date.minute}), current_guard}
    end
  end

  defp wakes_up(acc, wakes_up, current_guard) do
    falls_asleep = Map.get(acc[current_guard], "falls_asleep")

    guard =
      Enum.reduce(falls_asleep..(wakes_up - 1), acc[current_guard], fn min, guard ->
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
