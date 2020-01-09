defmodule Tesseract.Tree.TB.QueryTest do
  alias Tesseract.Math.Interval
  alias Tesseract.Tree
  alias Tesseract.Tree.TB.{Util, Query}
  alias Tesseract.Tree.Util.Insert

  use ExUnit.Case, async: true

  defp test_query_type(query_type, query_interval) do
    intervals = [
      test: {2, 3},
      test2: {2, 6},
      test3: {1, 5},
      test4: {3, 6},
      test5: {7, 9},
      test6: {0, 1}
    ]

    test_query_type(query_type, query_interval, intervals)
  end
  
  defp test_query_type(query_type, query_interval, intervals) do
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = apply(Query, query_type, [Query.select(:label), query_interval])
    results = Tree.query(tree, query)

    expected_labels =
      intervals
      |> Enum.filter(fn {_, interval} -> 
          Query.predicate(query_type, query_interval, interval)
        end)
      |> Keyword.keys()

    assert MapSet.new(expected_labels) === MapSet.new(results)
  end

  test "[TB] Query #0", _ do
    intervals = [
      test: Interval.make(2, 4),
      test2: Interval.make(3, 6),
      test3: Interval.make(10, 10),
      test4: Interval.make(3, 9),
      test5: Interval.make(1, 6),
      test6: Interval.make(2.5, 5.5)
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:label) |> Query.during({0.2, 7.5})
    results = Tree.query(tree, query)

    assert MapSet.new([:test, :test2, :test5, :test6]) === MapSet.new(results)
  end

  test "[TB] Query: type: equals.", _ do
    test_query_type(:equals, {2, 3})
  end

  test "[TB] Query: type: equals, querying lower boundry.", _ do
    intervals = [test: {0, 0}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:label) |> Query.equals({0, 0})
    results = Tree.query(tree, query)

    assert MapSet.new([:test]) === MapSet.new(results)
  end

  test "[TB] Query: type: equals, querying upper boundry.", _ do
    intervals = [test: {Util.lambda(), Util.lambda()}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:label) |> Query.equals({Util.lambda(), Util.lambda()})
    results = Tree.query(tree, query)

    assert MapSet.new([:test]) === MapSet.new(results)
  end

  test "[TB] Query test: starts.", _ do
    test_query_type(:starts, {2, 4})
  end

  test "[TB] Query test: started_by.", _ do
    test_query_type(:started_by, {2, 4})
  end

  test "[TB] Query test: meets.", _ do
    test_query_type(:meets, {6, 7})
  end

  test "[TB] Query test: met_by.", _ do
    test_query_type(:met_by, {6, 7})
  end

  test "[TB] Query test: finishes.", _ do
    test_query_type(:finishes, {2, 6})
  end

  test "[TB] Query test: finished_by.", _ do
    test_query_type(:finished_by, {5, 6})
  end

  test "[TB] Query test: before.", _ do
    test_query_type(:before, {4, 6})
    test_query_type(:before, {3, 5})
  end

  test "[TB] Query test: aftr.", _ do
    test_query_type(:aftr, {0, 2.5})
  end

  test "[TB] Query test: overlaps.", _ do
    test_query_type(:overlaps, {3.5, 7})
  end

  test "[TB] Query test: overlapped_by.", _ do
    test_query_type(:overlapped_by, {1, 2.5})
  end

  test "[TB] Query test: during.", _ do
    test_query_type(:during, {1, 7})
  end

  test "[TB] Query test: contains.", _ do
    test_query_type(:contains, {3, 4})
  end

  test "[TB] Query test: intersects.", _ do
    test_query_type(:intersects, {3.4, 4.5})

    intervals = [
      a: Interval.make(1, 2),
      b: Interval.make(2, 2),
      c: Interval.make(3, 2),
      d: Interval.make(2, 1),
      e: Interval.make(1, 1)
    ]

    test_query_type(:intersects, {0, 10}, intervals)
    test_query_type(:intersects, {0, 5}, intervals)
    test_query_type(:intersects, {0, 3}, intervals)
    test_query_type(:intersects, {0, 2}, intervals)
    test_query_type(:intersects, {1, 2}, intervals)
  end

  test "[TB] Query selection: label", _ do
    intervals = [
      a: Interval.make(1, 4),
      b: Interval.make(2, 6),
      c: Interval.make(3, 8),
      d: Interval.make(4, 5),
      e: Interval.make(2, 4)
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:label) |> Query.intersects({7, 9})
    results = Tree.query(tree, query)

    assert MapSet.new([:c]) === MapSet.new(results)
  end

  test "[TB] Query selection: geometry", _ do
    intervals = [
      a: Interval.make(1, 4),
      b: Interval.make(2, 6),
      c: Interval.make(3, 8),
      d: Interval.make(4, 5),
      e: Interval.make(2, 4)
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:geometry) |> Query.intersects({7, 9})
    results = Tree.query(tree, query)

    assert results === [intervals[:c]]
  end

  test "[TB] Query selection: record", _ do
    intervals = [
      a: Interval.make(1, 4),
      b: Interval.make(2, 6),
      c: Interval.make(3, 8),
      d: Interval.make(4, 5),
      e: Interval.make(2, 4)
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:record) |> Query.intersects({7, 9})
    results = Tree.query(tree, query)

    assert results === [records[:c]]
  end

  @tag :long_running
  test "[TB] Query test: 100x 1000 random queries on 1000 entries (on 1 tree)." do
    intervals =
      1..1000
      |> Enum.map(fn n ->
        {"point #{n}", Interval.make(:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()))}
      end)

    records = Insert.make_records(:tb, intervals)
    tree = Insert.make_tree_from_records(:tb, records)

    single_run = fn () ->
        # Random search
        1..1000
        |> Enum.map(fn _ -> 
            q = {max(0, Util.lambda() - 1), Util.lambda()}
            Query.select(:geometry) |> Query.intersects(q)
        end)
        |> Enum.each(fn query -> 
            results = Tree.query(tree, query)
            query_interval = query.input_interval
            
            results
            |> Enum.all?(&Interval.intersects?(query_interval, &1))
            |> assert
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end
end