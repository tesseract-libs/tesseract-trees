defmodule Tesseract.Tree.R.InsertTest do
  alias Tesseract.Tree.R
  alias Tesseract.Tree.R.Util
  alias Tesseract.Tree.R.Validation

  use ExUnit.Case, async: true

  test "insert a single entry into an empty R-tree", _ do
    {tree, cfg} = R.make(4)
    entry = Util.point2entry({{1, 1, 1}, {1, 1, 1}})

    {:ok, tree} = R.insert(tree, cfg, [entry])

    {:leaf, [^entry]} = tree

    1 = Util.count_entries(tree)
    true = Validation.tree_valid?(tree, cfg)
  end

  test "insert multiple entries to cause a split", _ do
    points = [
      a: {1, 1, 1},
      b: {2, 2, 2},
      c: {3, 3, 3},
      d: {4, 4, 4},
      e: {5, 5, 5},
      f: {6, 6, 6}
    ]

    {tree, cfg} = R.make(4)
    {:ok, new_tree} = R.insert(tree, cfg, Util.points2entries(points))

    {:internal,
     [
       {
         {{3, 3, 3}, {6, 6, 6}},
         {:leaf,
          [
            {{{6, 6, 6}, {6, 6, 6}}, :f},
            {{{3, 3, 3}, {3, 3, 3}}, :c},
            {{{4, 4, 4}, {4, 4, 4}}, :d},
            {{{5, 5, 5}, {5, 5, 5}}, :e}
          ]}
       },
       {
         {{1, 1, 1}, {2, 2, 2}},
         {:leaf,
          [
            {{{2, 2, 2}, {2, 2, 2}}, :b},
            {{{1, 1, 1}, {1, 1, 1}}, :a}
          ]}
       }
     ]} = new_tree

    6 = Util.count_entries(new_tree)
    true = Validation.tree_valid?(new_tree, cfg)
  end

  test "insert 100 entries", _ do
    entries =
      1..100
      |> Enum.map(fn n ->
        loc = {:rand.uniform(100), :rand.uniform(100), :rand.uniform(100)}
        {n, loc}
      end)
      |> Util.points2entries

    {tree, cfg} = R.make(4)
    {:ok, tree} = R.insert(tree, cfg, entries)

    100 = Util.count_entries(tree)
    true = Validation.tree_valid?(tree, cfg)
  end
end