defmodule Tesseract.Tree.TB.InsertTest do
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.TB.{Record, Interval, Node}

  use ExUnit.Case, async: true

  test "[TB] Insert a single entry into empty TB-tree.", _ do
    tree = TB.make()
    record = Record.make(:test, Interval.make(2, 4))

    {:ok, new_tree} = TB.insert(tree, record)

    new_root = TB.root(new_tree)
    new_root_records = Node.records(new_root)

    assert new_root_records === [record]
  end

  test "[TB] Insert multiple entries into empty TB-tree.", _ do
    tree = TB.make()
    record1 = Record.make(:test, Interval.make(2, 4))
    record2 = Record.make(:test2, Interval.make(3, 6))
    record3 = Record.make(:test3, Interval.make(10, 10))
    record4 = Record.make(:test4, Interval.make(3, 9))
    record5 = Record.make(:test5, Interval.make(1, 6))

    {:ok, new_tree} = TB.insert(tree, record1)
    {:ok, new_tree} = TB.insert(new_tree, record2)
    {:ok, new_tree} = TB.insert(new_tree, record3)
    {:ok, new_tree} = TB.insert(new_tree, record4)
    {:ok, new_tree} = TB.insert(new_tree, record5)

    new_root = TB.root(new_tree)

    assert MapSet.new(Node.records(new_root)) === MapSet.new([record5, record4, record3, record2, record1])
  end

  test "[TB] Insert multiple entries into empty TB-tree and cause a split.", _ do
    tree = TB.make(max_records_per_node: 5)
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

    new_root = TB.root(new_tree)
    low_child_records = new_root |> Node.left |> Node.records
    high_child_records = new_root |> Node.right |> Node.records

    assert MapSet.new(low_child_records) === MapSet.new([record1, record2, record4, record5, record6])
    assert MapSet.new(high_child_records) === MapSet.new([record3])
  end

  test "[TB] Insert 100 entries.", _ do
    records =
      1..100
      |> Enum.map(fn n ->
        Record.make("point #{n}", Interval.make(:rand.uniform(16), :rand.uniform(16)))
      end)

    _tree = 
      records
      |> Enum.reduce(TB.make(), fn record, tree -> 
        {:ok, new_tree} = TB.insert(tree, record)
        new_tree
      end)

    # TODO: assert something :)
  end
end