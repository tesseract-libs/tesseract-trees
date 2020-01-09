defmodule Tesseract.Tree.MPB.QueryTest do
  alias Tesseract.Tree
  alias Tesseract.Tree.Util.Insert
  alias Tesseract.Tree.MPB.Query

  use ExUnit.Case, async: true

  defp query(type, query_region) do
    points = [
      test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
      test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
      test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
      test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
      test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
    ]

    records = Insert.make_records(:mpb, points, true)
    query = apply(Query, type, [Query.select(:label), query_region])
    tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))

    Tree.query(tree, query)
  end

  test "[MPB] Query type: disjoint", _ do
    results = query(:disjoint, {{1, 2}, {0, 2}, {0, 2}, {1, 3}})
    assert MapSet.new(results) === MapSet.new([:test2, :test3, :test4, :test5])
  end

  test "[MPB] Query type: meets", _ do
    results = query(:meets, {{3, 5}, {0, 0}, {0, 0}, {0, 0}})
    assert MapSet.new(results) === MapSet.new([:test3])
  end

  test "[MPB] Query type: overlaps", _ do
    results = query(:overlaps, {{2, 2}, {1, 1}, {1, 1}, {1, 2}})
    assert MapSet.new(results) === MapSet.new([:test])

    results = query(:overlaps, {{1, 1}, {1, 1}, {3, 3}, {2, 2}})
    assert MapSet.new(results) === MapSet.new([:test5])
  end

  test "[MPB] Query type: equals", _ do
    results = query(:equals, {{1, 2}, {1, 1}, {1, 1}, {1, 2}})
    assert MapSet.new(results) === MapSet.new([:test])
  end

  test "[MPB] Query type: contains", _ do
    results = query(:contains, {{1, 2}, {1, 1}, {1, 1}, {2, 2}})
    assert MapSet.new(results) === MapSet.new([:test])
  end

  test "[MPB] Query type: contained_by", _ do
    results = query(:contained_by, {{1, 2}, {1, 1}, {1, 1}, {1, 3}})
    assert MapSet.new(results) === MapSet.new([:test])
  end

  test "[MPB] Query type: intersects", _ do
    results = query(:intersects, {{0, 10}, {0, 10}, {0, 10}, {0, 3}})
    assert MapSet.new(results) === MapSet.new([:test, :test2, :test3, :test4, :test5])

    results = query(:intersects, {{2, 2}, {1, 1}, {1, 1}, {2, 2}})
    assert MapSet.new(results) === MapSet.new([:test])
  end

  test "[MPB] Query selection: label", _ do
    points = [
      test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
      test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
      test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
      test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
      test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
    ]

    records = Insert.make_records(:mpb, points, true)
    query = Query.select(:label) |> Query.intersects({{2, 2}, {1, 1}, {1 ,1}, {2, 2}})
    tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))
    results = Tree.query(tree, query)

    assert results === [:test]
  end

  # test "[MPB] Query selection: geometry", _ do
  #   points = [
  #     test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
  #     test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
  #     test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
  #     test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
  #     test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
  #   ]

  #   records = Insert.make_records(:mpb, points, true)
  #   query = Query.select(:geometry) |> Query.intersects({{2, 2}, {1, 1}, {1 ,1}, {2, 2}})
  #   tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))
  #   results = Tree.query(tree, query)

  #   assert results === [{{1, 2}, {1, 1}, {1, 1}, {1, 2}}]
  # end

  # test "[MPB] Query selection: record", _ do
  #   points = [
  #     test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
  #     test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
  #     test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
  #     test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
  #     test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
  #   ]

  #   records = Insert.make_records(:mpb, points, true)
  #   query = Query.select(:geometry) |> Query.intersects({{2, 2}, {1, 1}, {1 ,1}, {2, 2}})
  #   tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))
  #   results = Tree.query(tree, query)

  #   assert results === [records[:test]]
  # end

  # test "[MPB] Query type: covers", _ do
  #   results = query(:covers, {{1, 2}, {1, 1}, {1, 1}, {1, 3}})
  #   assert MapSet.new(results) === MapSet.new([:test])
  # end

  # test "[MPB] Query type: covered by", _ do
  #   results = query(:covered_by, {{1, 2}, {1, 1}, {1, 1}, {1, 3}})
  #   assert MapSet.new(results) === MapSet.new([:test])
  # end

  # @tag :long_running
  # test "[TB] Query test: 10x 1000 random queries on 1000 entries (on 1 tree)." do
  #   points =
  #     1..1000
  #     |> Enum.map(fn n ->
  #       value_start = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}
  #       value_end = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}

  #       {"point #{n}", {value_start, value_end}}
  #     end)

  #   records = Insert.make_records(:mpb, points)
  #   tree = Insert.make_tree_from_records(:mpb, records)

  #   single_run = fn () ->
  #       # Random search
  #       1..1000
  #       |> Enum.map(fn _ -> 
  #           x_min = :rand.uniform(Util.lambda() - 1)
  #           x_max = x_min + :rand.uniform(Util.lambda() - x_min)
  #           y_min = :rand.uniform(Util.lambda() - 1)
  #           y_max = y_min + :rand.uniform(Util.lambda() - y_min)
  #           z_min = :rand.uniform(Util.lambda() - 1)
  #           z_max = z_min + :rand.uniform(Util.lambda() - z_min)
  #           t_min = :rand.uniform(Util.lambda() - 1)
  #           t_max = t_min + :rand.uniform(Util.lambda() - t_min)

  #           {{x_min, y_min, z_min, t_min}, {x_max, y_max, z_max, t_max}}
  #       end)
  #       |> Enum.each(fn search_region -> 
  #           _results = Tree.query(tree, search_region)

  #           # assert (
  #           #   true === 
  #           #     results
  #           #     |> Enum.all?(fn record ->  Util.rectangle_contains_point?(search_box, TB.Record.interval(record)) end)
  #           # )
  #       end)
  #     end

  #   1..10
  #   |> Enum.each(fn _ -> single_run.() end)
  # end

end