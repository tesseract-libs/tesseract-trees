defmodule Tesseract.Tree.TB.InsertTest do
  alias Tesseract.Tree.Util.Insert
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.TB.{Node, Interval}

  use ExUnit.Case, async: true

  test "[TB] Insert a single entry into empty TB-tree.", _ do
    records = Insert.make_records(:tb, [test: Interval.make(2, 4)])
    tree = Insert.make_tree_from_records(:tb, records)
    tree_records = tree |> TB.root |> Node.records

    assert MapSet.new(records) === MapSet.new(tree_records)
  end

  test "[TB] Insert multiple entries into empty TB-tree.", _ do
    points = [
      test: Interval.make(2, 4),
      test2: Interval.make(3, 6),
      test3: Interval.make(10, 10),
      test4: Interval.make(3, 9),
      test5: Interval.make(1, 6)
    ]

    records = Insert.make_records(:tb, points)
    tree = Insert.make_tree_from_records(:tb, records)
    root = TB.root(tree)

    assert MapSet.new(Node.records(root)) === MapSet.new(records)
  end

  test "[TB] Insert multiple entries into empty TB-tree and cause a split.", _ do
    points = [
      test: Interval.make(2, 4),
      test2: Interval.make(3, 6),
      test3: Interval.make(10, 10),
      test4: Interval.make(3, 9),
      test5: Interval.make(1, 6),
      test6: Interval.make(2.5, 5.5)
    ]

    labeled_records = Insert.make_records(:tb, points, true)
    tree = Insert.make_tree_from_records(:tb, Keyword.values(labeled_records), max_records_per_node: 5)
    root = TB.root(tree)
    low_child_records = root |> Node.left |> Node.records
    high_child_records = root |> Node.right |> Node.records

    assert MapSet.new(low_child_records) === MapSet.new(
      labeled_records
      |> Keyword.take([:test, :test2, :test4, :test5, :test6]) 
      |> Keyword.values()
    )

    assert MapSet.new(high_child_records) === MapSet.new(
      labeled_records
      |> Keyword.take([:test3]) 
      |> Keyword.values()
    )
  end

  test "[TB] Insert 100 entries.", _ do
    points =
      1..100
      |> Enum.map(fn n ->
        value = Interval.make(:rand.uniform(16), :rand.uniform(16))
        {"point #{n}", value}
      end)
    
    records = Insert.make_records(:tb, points)
    _tree = Insert.make_tree_from_records(:tb, records)

    # TODO: assert something :)
  end
end