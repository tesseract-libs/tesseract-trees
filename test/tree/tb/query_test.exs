defmodule Tesseract.Tree.TB.QueryTest do
  alias Tesseract.Tree
  alias Tesseract.Tree.TB.{Interval, Util, Query}
  alias Tesseract.Tree.Util.Insert

  use ExUnit.Case, async: true

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
    query = Query.select(:labels) |> Query.during(0.2, 7.5)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test, :test2, :test5, :test6])
  end

  test "[TB] Query: type = equals.", _ do
    intervals = [
      test: {2, 3},
      test2: {2, 2}
    ]

    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:labels) |> Query.equals(2, 3)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query: type = equals, querying lower boundry.", _ do
    intervals = [test: {0, 0}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:labels) |> Query.equals(0, 0)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query: type = equals, querying upper boundry.", _ do
    intervals = [test: {Util.lambda(), Util.lambda()}]
    records = Insert.make_records(:tb, intervals, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))
    query = Query.select(:labels) |> Query.equals(Util.lambda(), Util.lambda())
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query test: starts_between.", _ do
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
    query = Query.select(:labels) |> Query.starts(2, 4)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test])
  end

  test "[TB] Query test: started_by.", _ do
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
    query = Query.select(:labels) |> Query.started_by(2, 4)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test2])
  end

  test "[TB] Query test: meets.", _ do
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
    query = Query.select(:labels) |> Query.meets(6, 7)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test2, :test4])
  end

  test "[TB] Query test: met_by.", _ do
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
    query = Query.select(:labels) |> Query.met_by(6, 7)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test5])
  end

  test "[TB] Query test: finishes.", _ do
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
    query = Query.select(:labels) |> Query.finishes(2, 6)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test2, :test4])
  end

  test "[TB] Query test: finished_by.", _ do
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
    query = Query.select(:labels) |> Query.finished_by(5, 6)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test2, :test4])
  end

  test "[TB] Query test: before.", _ do
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
    query = Query.select(:labels) |> Query.before(4, 6)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test, :test6])
  end

  test "[TB] Query test: aftr.", _ do
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
    query = Query.select(:labels) |> Query.aftr(0, 2.5)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test4, :test5])
  end

  test "[TB] Query test: overlaps.", _ do
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
    query = Query.select(:labels) |> Query.overlaps(3.5, 7)
    results = Tree.query(tree, query)

    assert true === Insert.results_contain_all_records?(results, records, [:test2, :test3, :test4])
  end

  # @tag :long_running
  # test "[TB] Query test: 100x 1000 random queries on 1000 entries (on 1 tree)." do
  #   intervals =
  #     1..1000
  #     |> Enum.map(fn n ->
  #       {"point #{n}", Interval.make(:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()))}
  #     end)

  #   records = Insert.make_records(:tb, intervals)
  #   tree = Insert.make_tree_from_records(:tb, records)

  #   single_run = fn () ->
  #       # Random search
  #       1..1000
  #       |> Enum.map(fn _ -> 
  #           min_x = :rand.uniform(Util.lambda() / 2)
  #           min_y = min_x + :rand.uniform(Util.lambda() - 2 - min_x)
  #           max_x = min_x + :rand.uniform(Util.lambda() - 1 - min_x)
  #           max_y = max_x + :rand.uniform(Util.lambda() - max_x)

  #           {{min_x, min_y}, {max_x, max_y}}
  #       end)
  #       |> Enum.each(fn search_box -> 
  #           results = Tree.query(tree, search_box)
            
  #           assert (
  #             true === 
  #               results
  #               |> Enum.all?(fn record ->  Util.rectangle_contains_point?(search_box, TB.Record.interval(record)) end)
  #           )
  #       end)
  #     end

  #   1..100
  #   |> Enum.each(fn _ -> single_run.() end)
  # end
end