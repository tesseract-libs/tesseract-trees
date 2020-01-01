defmodule Tesseract.Tree.TB.QueryTest do
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.TB.{Record, Interval, Util}

  use ExUnit.Case, async: true

  test "[TB] Query test #0", _ do
    tree = TB.make()
    record1 = Record.make(:test, Interval.make(2, 4))
    record2 = Record.make(:test2, Interval.make(3, 6))
    record3 = Record.make(:test3, Interval.make(10, 10))
    record4 = Record.make(:test4, Interval.make(3, 9))
    record5 = Record.make(:test5, Interval.make(1, 6))
    record6 = Record.make(:test6, Interval.make(2.5, 5.5))

    {:ok, new_tree} = TB.insert(tree, record1)
    {:ok, new_tree} = TB.insert(new_tree, record2)
    {:ok, new_tree} = TB.insert(new_tree, record3)
    {:ok, new_tree} = TB.insert(new_tree, record4)
    {:ok, new_tree} = TB.insert(new_tree, record5)
    {:ok, new_tree} = TB.insert(new_tree, record6)

    results = 
      new_tree
      |> TB.query({{0.2, 5}, {6, 7.5}})
      |> MapSet.new

    assert results === MapSet.new([record2, record5, record6])
  end

  @tag :long_running
  test "[TB] Query test: 100x 1000 random queries on 1000 entries (on 1 tree)." do
    records =
      1..1000
      |> Enum.map(fn n ->
        Record.make("point #{n}", Interval.make(:rand.uniform(16), :rand.uniform(16)))
      end)

    tree =
      records
      |> Enum.reduce(TB.make(), 
        fn record, tree -> 
          {:ok, new_tree} = TB.insert(tree, record) 
          new_tree
        end)

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
            results = TB.query(tree, search_box)
            
            assert (
              true === 
                results
                |> Enum.all?(fn record ->  Util.rectangle_contains_point?(search_box, Record.interval(record)) end)
            )
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end
end