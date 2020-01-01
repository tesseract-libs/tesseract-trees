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
    record3 = Record.make(:test3, Interval.make(7, 9))

    {:ok, new_tree} = TB.insert(tree, record1)
    {:ok, new_tree} = TB.insert(new_tree, record2)
    {:ok, new_tree} = TB.insert(new_tree, record3)

    new_root = TB.root(new_tree)
    new_root_records = Node.records(new_root)

    assert new_root_records === [record3, record2, record1]
  end
end