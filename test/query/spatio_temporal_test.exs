defmodule Tesseract.Query.SpaceTimeTest do
  alias Tesseract.Query.SpatioTemporal, as: Query
  alias Tesseract.Tree.TB.Interval

  use ExUnit.Case, async: true

  test "Space-Time timepoint-point query (point in space and time) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:labels)
      |> Query.at_time(6)
      |> Query.at_point({3, 4, 5})
      |> Query.to_mpb_query()

    assert query.selection === :labels
    assert query.query_type === :intersects
    
    c_x = query.component_queries[:x] |> hd
    assert c_x.query_type === :intersects
    assert c_x.input_interval === Interval.make(3, 3)

    c_y = query.component_queries[:y] |> hd
    assert c_y.query_type === :intersects
    assert c_y.input_interval === Interval.make(4, 4)
    
    c_z = query.component_queries[:z] |> hd
    assert c_z.query_type === :intersects
    assert c_z.input_interval === Interval.make(5, 5)
    
    c_t = query.component_queries[:t] |> hd
    assert c_t.query_type === :intersects
    assert c_t.input_interval === Interval.make(6, 6)
  end

  test "Space-Time timeslice-point query (interval in time, point in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:labels)
      |> Query.between_times(Interval.make(6, 10))
      |> Query.at_point({3, 4, 5})
      |> Query.to_mpb_query()

    assert query.selection === :labels
    assert query.query_type === :intersects
    
    c_x = query.component_queries[:x] |> hd
    assert c_x.query_type === :intersects
    assert c_x.input_interval === Interval.make(3, 3)

    c_y = query.component_queries[:y] |> hd
    assert c_y.query_type === :intersects
    assert c_y.input_interval === Interval.make(4, 4)
    
    c_z = query.component_queries[:z] |> hd
    assert c_z.query_type === :intersects
    assert c_z.input_interval === Interval.make(5, 5)
    
    c_t = query.component_queries[:t] |> hd
    assert c_t.query_type === :intersects
    assert c_t.input_interval === Interval.make(6, 10)
  end

  test "Space-Time timeslice-region query (interval in time, box in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:labels)
      |> Query.between_times(Interval.make(6, 10))
      |> Query.in_space({{1, 1, 1}, {3, 3, 3}})
      |> Query.to_mpb_query()

    assert query.selection === :labels
    assert query.query_type === :intersects
    
    c_x = query.component_queries[:x] |> hd
    assert c_x.query_type === :intersects
    assert c_x.input_interval === Interval.make(1, 3)

    c_y = query.component_queries[:y] |> hd
    assert c_y.query_type === :intersects
    assert c_y.input_interval === Interval.make(1, 3)
    
    c_z = query.component_queries[:z] |> hd
    assert c_z.query_type === :intersects
    assert c_z.input_interval === Interval.make(1, 3)
    
    c_t = query.component_queries[:t] |> hd
    assert c_t.query_type === :intersects
    assert c_t.input_interval === Interval.make(6, 10)
  end

  test "Space-Time timepoint-region query (point in time, box in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:labels)
      |> Query.at_time(6)
      |> Query.in_space({{1, 1, 1}, {3, 3, 3}})
      |> Query.to_mpb_query()

    assert query.selection === :labels
    assert query.query_type === :intersects
    
    c_x = query.component_queries[:x] |> hd
    assert c_x.query_type === :intersects
    assert c_x.input_interval === Interval.make(1, 3)

    c_y = query.component_queries[:y] |> hd
    assert c_y.query_type === :intersects
    assert c_y.input_interval === Interval.make(1, 3)
    
    c_z = query.component_queries[:z] |> hd
    assert c_z.query_type === :intersects
    assert c_z.input_interval === Interval.make(1, 3)
    
    c_t = query.component_queries[:t] |> hd
    assert c_t.query_type === :intersects
    assert c_t.input_interval === Interval.make(6, 6)
  end
end