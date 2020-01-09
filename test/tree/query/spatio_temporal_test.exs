defmodule Tesseract.Tree.Query.SpatioTemporalTest do
  alias Tesseract.Tree.Query.SpatioTemporal, as: Query
  alias Tesseract.Math.Interval
  alias Tesseract.Tree.Util.Insert
  alias Tesseract.Tree

  use ExUnit.Case, async: true

  test "Spatio-Temporal timepoint-point query (point in space and time) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:label)
      |> Query.at_time(6)
      |> Query.at_point({3, 4, 5})
      |> Query.to_mpb_query()

    assert query.selection === :label
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

  test "Spatio-Temporal timeslice-point query (interval in time, point in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:label)
      |> Query.between_times(Interval.make(6, 10))
      |> Query.at_point({3, 4, 5})
      |> Query.to_mpb_query()

    assert query.selection === :label
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

  test "Spatio-Temporal timeslice-region query (interval in time, box in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:label)
      |> Query.between_times(Interval.make(6, 10))
      |> Query.in_space({{1, 1, 1}, {3, 3, 3}})
      |> Query.to_mpb_query()

    assert query.selection === :label
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

  test "Spatio-Temporal timepoint-region query (point in time, box in space) can be successfully coverted to a MPB query", _ do
    query =
      Query.select(:label)
      |> Query.at_time(6)
      |> Query.in_space({{1, 1, 1}, {3, 3, 3}})
      |> Query.to_mpb_query()

    assert query.selection === :label
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

  test "Spatio-Temporal label-only query can be constructed", _ do
    only_labels = [:a, :b, :c]

    query =
      Query.select(:label)
      |> Query.with_labels(only_labels)

    assert MapSet.new(query.labels) === MapSet.new(only_labels)
  end

  defp make_tree(objects) do
    Insert.make_tree_from_records(:mpb, Insert.make_records(:mpb, objects))
  end

  test "Spatio-Temporal timepoint-point query", _ do
    tree = make_tree([
      a: {{1, 1, 0, 1}, {1, 1, 0, 2}},
      b: {{2, 2, 0, 1}, {2, 2, 0, 2}},
      c: {{3, 3, 0, 1}, {3, 3, 0, 2}},
      d: {{4, 4, 0, 1}, {4, 5, 0, 2}},
      e: {{5, 5, 0, 1}, {5, 5, 0, 2}}
    ])

    q = 
      :label
      |> Query.select()
      |> Query.at_time(2)
      |> Query.at_point({4, 5, 0})
      |> Query.to_mpb_query()

    assert MapSet.new(Tree.query(tree, q)) === MapSet.new([:d])
  end

  test "Spatio-Temporal timepoint-region query", _ do
    tree = make_tree([
      a: {{1, 1, 0, 1}, {1, 1, 0, 2}},
      b: {{2, 2, 0, 1}, {2, 2, 0, 2}},
      c: {{3, 3, 0, 1}, {3, 3, 0, 2}},
      d: {{4, 4, 0, 1}, {4, 5, 0, 2}},
      e: {{5, 5, 0, 1}, {5, 5, 0, 2}}
    ])

    q =
      :label
      |> Query.select()
      |> Query.at_time(2)
      |> Query.in_space({{1, 1, 0}, {2, 2, 0}})
      |> Query.to_mpb_query

    assert MapSet.new(Tree.query(tree, q)) === MapSet.new([:a, :b])
  end

  test "Spatio-Temporal timeslice-point query", _ do
    tree = make_tree([
      a: {{1, 1, 0, 1}, {1, 1, 0, 2}},
      b: {{2, 2, 0, 1}, {2, 2, 0, 2}},
      c: {{3, 3, 0, 1}, {3, 3, 0, 2}},
      d: {{4, 4, 0, 1}, {4, 5, 0, 2}},
      e: {{5, 5, 0, 1}, {5, 5, 0, 2}}
    ])

    q =
      :label
      |> Query.select()
      |> Query.between_times({1, 2})
      |> Query.at_point({4, 5, 0})
      |> Query.to_mpb_query

    assert MapSet.new(Tree.query(tree, q)) === MapSet.new([:d])
  end

  test "Spatio-Temporal timeslice-region query", _ do
    tree = make_tree([
      a: {{1, 1, 0, 1}, {1, 1, 0, 2}},
      b: {{2, 2, 0, 1}, {2, 2, 0, 2}},
      c: {{3, 3, 0, 1}, {3, 3, 0, 2}},
      d: {{4, 4, 0, 1}, {4, 5, 0, 2}},
      e: {{5, 5, 0, 1}, {5, 5, 0, 2}}
    ])

    q =
      :label
      |> Query.select()
      |> Query.between_times({1, 2})
      |> Query.in_space({{4, 5, 0}, {5, 5, 0}})
      |> Query.to_mpb_query

    assert MapSet.new(Tree.query(tree, q)) === MapSet.new([:d, :e])
  end
end