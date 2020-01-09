defmodule Tesseract.Tree.Query.SpatioTemporal do
  alias Tesseract.Math.Interval
  alias Tesseract.Tree.MPB.Query, as: MPBQuery
  
  defstruct [
    ref: nil,
    selection: nil,
    labels: [],
    t: nil,
    x: nil,
    y: nil,
    z: nil
  ]

  def select(selection) when is_atom(selection) do
    %__MODULE__{selection: selection, ref: make_ref()}
  end

  def at_time(%__MODULE__{} = query, t) do
    %{query | t: Interval.make(t, t)}
  end

  def between_times(%__MODULE__{} = query, time_interval) do
    %{query | t: time_interval}
  end

  def in_space(%__MODULE__{} = query, {{x_min, y_min, z_min}, {x_max, y_max, z_max}}) do
    query
    |> Map.put(:x, Interval.make(x_min, x_max))
    |> Map.put(:y, Interval.make(y_min, y_max))
    |> Map.put(:z, Interval.make(z_min, z_max))
  end

  def at_point(%__MODULE__{} = query, {x, y, z}) do
    query
    |> Map.put(:x, Interval.make(x, x))
    |> Map.put(:y, Interval.make(y, y))
    |> Map.put(:z, Interval.make(z, z))
  end

  def with_labels(%__MODULE__{} = query, labels) when is_list(labels) do
    query
    |> Map.put(:labels, labels)
  end

  def to_mpb_query(%__MODULE__{} = query) do
    query.selection
    |> MPBQuery.select
    |> MPBQuery.intersects({query.x, query.y, query.z, query.t})
  end
end

defimpl Tesseract.Tree.Query, for: Tesseract.Tree.Query.SpatioTemporal  do
  def ref(%Tesseract.Tree.Query.SpatioTemporal{} = query), do: query.ref

  def select(%Tesseract.Tree.Query.SpatioTemporal{} = _query, _results) do
    raise "TODO :)"
  end
end