defmodule Tesseract.Tree.MPB.QueryTest do
  alias Tesseract.Tree
  alias Tesseract.Tree.Util.Insert
  alias Tesseract.Tree.TB.Util

  use ExUnit.Case, async: true

  @tag :mpb
  test "[MPB] Query test #0", _ do
    points = [
      test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
      test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
      test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
      test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
      test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
    ]

    records = Insert.make_records(:mpb, points, true)
    tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))

    results = 
      tree
      |> Tree.query({{0.5, 1, 1, 1}, {2.5, 1, 1, 2}})
      |> MapSet.new

    assert results === ( 
      records 
      |> Keyword.take([:test]) 
      |> Keyword.values
      |> MapSet.new
    )
  end

  @tag :keke
  test "[MPB] Query test - exact match.", _ do
    points = [
      test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
      test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
      test3: {{4, 3, 3, 1}, {2, 3, 3, 2}},
      test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
      test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
    ]

    records = Insert.make_records(:mpb, points, true)
    tree = Insert.make_tree_from_records(:mpb, Keyword.values(records))

    IO.inspect tree

    results =
      tree
      |> Tree.query({{1, 1, 3, 2}, {1, 1, 3, 2}})
      |> MapSet.new

    assert results === (
      records
      |> Keyword.take([:test5])
      |> MapSet.new
    )
  end

  @tag :long_running
  @tag :mpb
  test "[TB] Query test: 10x 1000 random queries on 1000 entries (on 1 tree)." do
    points =
      1..1000
      |> Enum.map(fn n ->
        value_start = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}
        value_end = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}

        {"point #{n}", {value_start, value_end}}
      end)

    records = Insert.make_records(:mpb, points)
    tree = Insert.make_tree_from_records(:mpb, records)

    single_run = fn () ->
        # Random search
        1..1000
        |> Enum.map(fn _ -> 
            x_min = :rand.uniform(Util.lambda() - 1)
            x_max = x_min + :rand.uniform(Util.lambda() - x_min)
            y_min = :rand.uniform(Util.lambda() - 1)
            y_max = y_min + :rand.uniform(Util.lambda() - y_min)
            z_min = :rand.uniform(Util.lambda() - 1)
            z_max = z_min + :rand.uniform(Util.lambda() - z_min)
            t_min = :rand.uniform(Util.lambda() - 1)
            t_max = t_min + :rand.uniform(Util.lambda() - t_min)

            {{x_min, y_min, z_min, t_min}, {x_max, y_max, z_max, t_max}}
        end)
        |> Enum.each(fn search_region -> 
            _results = Tree.query(tree, search_region)

            # assert (
            #   true === 
            #     results
            #     |> Enum.all?(fn record ->  Util.rectangle_contains_point?(search_box, TB.Record.interval(record)) end)
            # )
        end)
      end

    1..10
    |> Enum.each(fn _ -> single_run.() end)
  end

end