defmodule Tesseract.Tree.R.QueryTest do
  alias Tesseract.Tree.R
  alias Tesseract.Tree.R.Validation
  alias Tesseract.Tree.R.Util
  alias Tesseract.Geometry.Box

  use ExUnit.Case, async: true

  test "Query test: simple #1" do
    points = [
      a: {1, 1, 1},
      b: {2, 2, 2},
      c: {3, 3, 3},
      d: {4, 4, 4},
      e: {5, 5, 5},
      f: {6, 6, 6}
    ]

    {tree, cfg} = R.make(4)
    {:ok, tree} = R.insert(tree, cfg, Util.points2entries(points))
    true = Validation.tree_valid?(tree, cfg)

    [:a] = R.query(tree, {{0, 0, 0}, {1.5, 1.5, 1.5}}) |> Enum.map(&Util.entry_value/1)
    [:b, :a] = R.query(tree, {{0, 0, 0}, {2, 2, 2}}) |> Enum.map(&Util.entry_value/1)
    [:c, :d, :e] = R.query(tree, {{2.6, 2.7, 2.9}, {5.05, 5.02, 5.1}}) |> Enum.map(&Util.entry_value/1)
  end

  @tag :long_running
  test "Query test: random querying on 1000 entries." do
    single_run = fn () ->
        entries =
        1..1000
        |> Enum.map(fn n ->
            loc = {:rand.uniform(100), :rand.uniform(100), :rand.uniform(100)}
            {n, loc}
        end)
        |> Util.points2entries

        {tree, cfg} = R.make(4)
        {:ok, tree} = R.insert(tree, cfg, entries)
        true = Validation.tree_valid?(tree, cfg)

        # Random search
        1..1000
        |> Enum.map(fn _ -> 
            a = {:rand.uniform(100), :rand.uniform(100), :rand.uniform(100)}
            b = {:rand.uniform(100), :rand.uniform(100), :rand.uniform(100)}

            {min(a, b), max(a, b)}
        end)
        |> Enum.each(fn search_box -> 
            results = R.query(tree, search_box)
            
            true = 
                results
                |> Enum.all?(fn {mbb, _} ->  Box.intersects?(search_box, mbb) end)
            
            true = 
                results
                |> Enum.filter(fn {mbb, _} -> Box.intersects?(search_box, mbb) end)
                |> Enum.all?(&(Enum.member?(results, &1)))
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end

end