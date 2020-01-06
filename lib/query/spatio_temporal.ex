defmodule Tesseract.Query.SpatioTemporal do
  alias Tesseract.Tree.TB.Interval
  alias Tesseract.Tree.MPB.Query, as: MPBQuery
  
  defstruct [
    ref: nil, 
    selection: nil,
    t: nil,
    x: nil,
    y: nil,
    z: nil
  ]

  def select(:labels) do
    %__MODULE__{selection: :labels, ref: make_ref()}
  end

  def at_time(%__MODULE__{} = query, t) do
    %{query | t: Interval.make(t, t)}
  end

  def between_times(%__MODULE__{} = query, time_interval) do
    %{query | t: time_interval}
  end

  def in_space(%__MODULE__{} = query, {x_interval, y_interval, z_interval}) do
    query
    |> Map.put(:x, x_interval)
    |> Map.put(:y, y_interval)
    |> Map.put(:z, z_interval)
  end

  def at_point(%__MODULE__{} = query, {x, y, z}) do
    query
    |> Map.put(:x, Interval.make(x, x))
    |> Map.put(:y, Interval.make(y, y))
    |> Map.put(:z, Interval.make(z, z))
  end

  def to_mpb_query(%__MODULE__{} = query) do
    query.selection
    |> MPBQuery.select
    |> MPBQuery.intersects({query.x, query.y, query.z, query.t})
  end

end