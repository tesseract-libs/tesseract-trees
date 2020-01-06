defmodule Tesseract.Tree.TB.Query do
  alias Tesseract.Tree.TB.{Util, Interval}

  defstruct [ref: nil, selection: nil,query_type: nil, query_box: nil, input_interval: nil]

  def select(selection) do
    %__MODULE__{selection: selection, ref: make_ref()}
  end

  def select(%__MODULE__{} = query, selection) do
    %{query | selection: selection}
  end

  defp set_query_type(%__MODULE__{} = query, type) do
    %{query | query_type: type}
  end

  defp set_query_box(%__MODULE__{} = query, query_box) do
    %{query | query_box: query_box}
  end

  defp set_input_interval(%__MODULE__{} = query, input_interval) do
    %{query | input_interval: input_interval}
  end

  # Intervals which are exactly the same.
  def equals(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:equals)
    |> set_query_box({{value_start, value_end}, {value_start, value_end}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are: 
  # - started exactly at the start of the query interval and
  # - ended inside the query interval.
  def starts(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:starts)
    |> set_query_box({{value_start, value_start}, {value_start, value_end}})
    |> set_input_interval(query_interval)
  end 

  # Intervals which are:
  #  - started exactly at the start of query interval and
  #  - ended after the end of query interval.
  def started_by(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:started_by)
    |> set_query_box({{value_start, value_end}, {value_start, Util.lambda()}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are ended exactly where query interval starts.
  def meets(%__MODULE__{} = query, {value_start, value_end} = query_interval) do    
    query
    |> set_query_type(:meets)
    |> set_query_box({{0, value_start}, {value_start, value_start}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started exactly where query interval ends. 
  def met_by(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:met_by)
    |> set_query_box({{value_end, value_end}, {value_end, Util.lambda()}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started inside the query interval and end exactly at the end of query interval.
  def finishes(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:finishes)
    |> set_query_box({{value_start, value_end}, {value_end, value_end}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started before the query interval starts and end exactly at the end of query interval.
  def finished_by(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:finished_by)
    |> set_query_box({{0, value_end}, {value_start, value_end}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started and ended before the query interval.
  def before(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:before)
    |> set_query_box({{0, 0}, {value_start, value_start}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started after the end of query interval.
  def aftr(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:aftr)
    |> set_query_box({{value_end, value_end}, {Util.lambda(), Util.lambda()}})
    |> set_input_interval(query_interval)
  end

  # Intervals which start before the query interval and end inside the query interval.
  def overlaps(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:overlaps)
    |> set_query_box({{0, value_start}, {value_start, value_end}})
    |> set_input_interval(query_interval)
  end

  # Intervals which start inside the query interval but end after the end of query interval.
  def overlapped_by(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:overlapped_by)
    |> set_query_box({{value_start, value_end}, {value_end, Util.lambda()}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are fully contained whitin the query interval.
  def during(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:during)
    |> set_query_box({{value_start, value_start}, {value_end, value_end}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started before the start of query interval and ended after the end of query interval.
  def contains(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:contains)
    |> set_query_box({{0, value_end}, {value_start, Util.lambda()}})
    |> set_input_interval(query_interval)
  end

  # Intervals which are started before the end of query interval and end after the start of the query interval.
  def intersects(%__MODULE__{} = query, {value_start, value_end} = query_interval) do
    query
    |> set_query_type(:intersects)
    |> set_query_box({{0, value_end}, {value_start, Util.lambda()}})
    |> set_input_interval(query_interval)
  end

end