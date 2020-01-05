defmodule Tesseract.Tree.TB.QueryTest do
  alias Tesseract.Tree
  alias Tesseract.Tree.TB.{Interval, Util, Query, Record}
  alias Tesseract.Tree.Util.Insert

  use ExUnit.Case, async: true

  defp test_query_type(query_type, query_interval, expected_record_labels) do
    intervals = [
      test: {2, 3},
      test2: {2, 6},
      test3: {1, 5},
      test4: {3, 6},
      test5: {7, 9},
      test6: {0, 1}
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = apply(Query, query_type, [Query.select(:labels), query_interval])
    results = Tree.query(tree, query)

    assert Insert.results_contain_all_records?(results, records, expected_record_labels)
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
    query = Query.select(:labels) |> Query.during({0.2, 7.5})
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test, :test2, :test5, :test6])
  end

  test "[TB] Query: type = equals.", _ do
    test_query_type(:equals, {2, 3}, [:test])
  end

  test "[TB] Query: type = equals, querying lower boundry.", _ do
    intervals = [test: {0, 0}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:labels) |> Query.equals({0, 0})
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query: type = equals, querying upper boundry.", _ do
    intervals = [test: {Util.lambda(), Util.lambda()}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:labels) |> Query.equals({Util.lambda(), Util.lambda()})
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query test: starts.", _ do
    test_query_type(:starts, {2, 4}, [:test])
  end

  test "[TB] Query test: started_by.", _ do
    test_query_type(:started_by, {2, 4}, [:test2])
  end

  test "[TB] Query test: meets.", _ do
    test_query_type(:meets, {6, 7}, [:test2, :test4])
  end

  test "[TB] Query test: met_by.", _ do
    test_query_type(:met_by, {6, 7}, [:test5])
  end

  test "[TB] Query test: finishes.", _ do
    test_query_type(:finishes, {2, 6}, [:test2, :test4])
  end

  test "[TB] Query test: finished_by.", _ do
    test_query_type(:finished_by, {5, 6}, [:test2, :test4])
  end

  test "[TB] Query test: before.", _ do
    test_query_type(:before, {4, 6}, [:test, :test6])
  end

  test "[TB] Query test: aftr.", _ do
    test_query_type(:aftr, {0, 2.5}, [:test4, :test5])
  end

  test "[TB] Query test: overlaps.", _ do
    test_query_type(:overlaps, {3.5, 7}, [:test2, :test3, :test4])
  end

  test "[TB] Query test: overlapped_by.", _ do
    test_query_type(:overlapped_by, {1, 2.5}, [:test, :test2, :test3])
  end

  test "[TB] Query test: during.", _ do
    test_query_type(:during, {1, 7}, [:test, :test2, :test3, :test4])
  end

  test "[TB] Query test: contains.", _ do
    test_query_type(:contains, {3, 4}, [:test2, :test3, :test4])
  end

  test "[TB] Query test: intersects.", _ do
    test_query_type(:intersects, {3.4, 4.5}, [:test2, :test3, :test4])
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
            Query.select(:labels) |> Query.intersects(q)
        end)
        |> Enum.each(fn query -> 
            results = Tree.query(tree, query)
            query_interval = query.input_interval
            
            results
            |> Enum.map(&Record.interval/1)
            |> Enum.all?(&Interval.intersects?(query_interval, &1))
            |> assert
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end
end