defmodule Tesseract.Tree.TB.QueryTest do
  alias Tesseract.Tree
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.TB.{Interval, Util}
  alias Tesseract.Tree.Util.Insert

  use ExUnit.Case, async: true

  test "[TB] Query test #0", _ do
    points = [
      test: Interval.make(2, 4),
      test2: Interval.make(3, 6),
      test3: Interval.make(10, 10),
      test4: Interval.make(3, 9),
      test5: Interval.make(1, 6),
      test6: Interval.make(2.5, 5.5)
    ]

    records = Insert.make_records(:tb, points, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(records))

    results = 
      tree
      |> Tree.query({{0.2, 5}, {6, 7.5}})
      |> MapSet.new

    assert results === ( 
      records 
      |> Keyword.take([:test2, :test5, :test6]) 
      |> Keyword.values
      |> MapSet.new
    )
  end

  @tag :long_running
  test "[TB] Query test: 100x 1000 random queries on 1000 entries (on 1 tree)." do
    points =
      1..1000
      |> Enum.map(fn n ->
        {"point #{n}", Interval.make(:rand.uniform(16), :rand.uniform(16))}
      end)

    records = Insert.make_records(:tb, points)
    tree = Insert.make_tree_from_records(:tb, records)

    single_run = fn () ->
        # Random search
        1..1000
        |> Enum.map(fn _ -> 
            min_x = :rand.uniform(8)
            min_y = min_x + :rand.uniform(14 - min_x)
            max_x = min_x + :rand.uniform(15 - min_x)
            max_y = max_x + :rand.uniform(16 - max_x)

            {{min_x, min_y}, {max_x, max_y}}
        end)
        |> Enum.each(fn search_box -> 
            results = Tree.query(tree, search_box)
            
            assert (
              true === 
                results
                |> Enum.all?(fn record ->  Util.rectangle_contains_point?(search_box, TB.Record.interval(record)) end)
            )
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end
end