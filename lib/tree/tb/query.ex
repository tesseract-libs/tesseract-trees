defmodule Tesseract.Tree.TB.Query do
  alias Tesseract.Tree.TB.Util

  defstruct [selection: nil, query_type: nil, query_box: nil]

  def select(selection) do
    %__MODULE__{selection: selection}
  end

  def select(%__MODULE__{} = query, selection) do
    %{query | selection: selection}
  end

  # Intervals which are exactly the same.
  def equals(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :equals}
    query = %{query | query_box: {{value_start, value_end}, {value_start, value_end}}}
  end

  # Intervals which are: 
  # - started exactly at the start of the query interval and
  # - ended inside the query interval.
  def starts(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :starts}
    query = %{query | query_box: {{value_start, value_start}, {value_start, value_end}}}
  end 

  # Intervals which are:
  #  - started exactly at the start of query interval and
  #  - ended after the end of query interval.
  def started_by(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :started_by}
    query = %{query | query_box: {{value_start, value_end}, {value_start, Util.lambda()}}}
  end

  # Intervals which are ended exactly where query interval starts.
  def meets(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :meets}
    query = %{query | query_box: {{0, value_start}, {value_start, value_start}}}
  end

  # Intervals which are started exactly where query interval ends. 
  def met_by(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :met_by}
    query = %{query | query_box: {{value_end, value_end}, {value_end, Util.lambda()}}}
  end

  # Intervals which are started inside the query interval and end exactly at the end of query interval.
  def finishes(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :finishes}
    query = %{query | query_box: {{value_start, value_end}, {value_end, value_end}}}
  end

  # Intervals which are started before the query interval starts and end exactly at the end of query interval.
  def finished_by(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :finished_by}
    query = %{query | query_box: {{0, value_end}, {value_start, value_end}}}
  end

  # Intervals which are started and ended before the query interval.
  def before(%__MODULE__{} = query, value_start, _value_end) do
    query = %{query | query_type: :before}
    query = %{query | query_box: {{0, 0}, {value_start, value_start}}}
  end

  # Intervals which are started after the end of query interval.
  def aftr(%__MODULE__{} = query, _value_start, value_end) do
    query = %{query | query_type: :after}
    query = %{query | query_box: {{value_end, value_end}, {Util.lambda(), Util.lambda()}}}
  end

  # Intervals which start before the query interval and end inside the query interval.
  def overlaps(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :overlaps}
    query = %{query | query_box: {{0, value_start}, {value_start, value_end}}}
  end

  # Intervals which start inside the query interval but end after the end of query interval.
  def overlapped_by(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :overlapped_by}
    query = %{query | query_box: {{value_start, value_end}, {value_end, Util.lambda()}}}
  end

  # Intervals which are fully contained whitin the query interval.
  def during(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :during}
    query = %{query | query_box: {{value_start, value_start}, {value_end, value_end}}}
  end

  # Intervals which are started before the start of query interval and ended after the end of query interval.
  def contains(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :contains}
    query = %{query | query_box: {{0, value_end}, {value_start, Util.lambda()}}}
  end

  # Intervals which are started before the end of query interval and end after the start of the query interval.
  def intersects(%__MODULE__{} = query, value_start, value_end) do
    query = %{query | query_type: :contains}
    query = %{query | query_box: {{0, value_end}, {value_start, Util.lambda()}}}
  end

end