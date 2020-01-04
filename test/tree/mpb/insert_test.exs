defmodule Tesseract.Tree.MPB.InsertTest do
  alias Tesseract.Tree.Util.Insert
  alias Tesseract.Tree.TB.Util

  use ExUnit.Case, async: true

  @tag :mpb
  test "[MPB] Insert a single entry into empty MPB-tree.", _ do
    point_start = {1, 1, 1, 1}
    point_end = {2, 1, 1, 2}

    records = Insert.make_records(:mpb, [test: {point_start, point_end}])
    tree = Insert.make_tree_from_records(:mpb, records)

    # tree_records = tree |> TB.root |> Node.records
    # assert MapSet.new(records) === MapSet.new(tree_records)
    # TODO: assert something :)
  end

  @tag :mpb
  test "[MPB] Insert multiple entries into empty MPB-tree.", _ do
    points = [
      test: {{1, 1, 1, 1}, {2, 1, 1, 2}},
      test2: {{2, 2, 2, 1}, {2, 2, 3, 2}},
      test3: {{3, 3, 3, 1}, {2, 3, 3, 2}},
      test4: {{2, 3, 3, 1}, {1, 3, 3, 2}},
      test5: {{1, 1, 2, 1}, {1, 1, 3, 2}}
    ]

    records = Insert.make_records(:mpb, points)
    tree = Insert.make_tree_from_records(:mpb, records)

    # IO.inspect tree

    # root = TB.root(tree)
    # assert MapSet.new(Node.records(root)) === MapSet.new(records)
  end

  @tag :mpb
  test "[MPB] Insert 100 entries.", _ do
    points =
      1..100
      |> Enum.map(fn n ->
        value_start = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}
        value_end = {:rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda()), :rand.uniform(Util.lambda())}

        {"point #{n}", {value_start, value_end}}
      end)
    
    records = Insert.make_records(:mpb, points)
    _tree = Insert.make_tree_from_records(:mpb, records)

    # TODO: assert something :)
  end
end