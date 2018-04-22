defmodule Tesseract.Tree.R.DeleteTest do
  alias Tesseract.Tree.R
  alias Tesseract.Tree.R.Validation
  alias Tesseract.Tree.R.Util
  alias Tesseract.Geometry.Box

  use ExUnit.Case, async: true

  test "Delete test: simple case #1" do
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

    {:ok, new_tree} = R.delete(new_tree, cfg, {{{2, 2, 2}, {2, 2, 2}}, :b})
    5 = Util.count_entries(new_tree)
    true = Validation.tree_valid?(new_tree, cfg)
  end

  test "Delete test: case #2" do
    points = [
      a: {1, 1, 1},
      b: {2, 2, 2},
      c: {3, 3, 3},
      d: {4, 4, 4},
      e: {5, 5, 5},
      f: {6, 6, 6},
      g: {7, 8, 3},
      h: {4, 9, 2},
      i: {3, 9, 6},
      j: {7, 3, 9},
      k: {5, 7, 1},
      l: {5, 2, 1},
      m: {9, 7, 3},
      n: {8, 5, 3},
      o: {2, 2, 7},
      p: {7, 5, 4}
    ]

    {tree, cfg} = R.make(4)
    {:ok, new_tree} = R.insert(tree, cfg, Util.points2entries(points))
    true = Validation.tree_valid?(new_tree, cfg)

    {:internal,[
       {
         {{1, 1, 1}, {9, 9, 3}},
          {:internal, [
            {
              {{2, 2, 2}, {9, 9, 3}}, 
              {:leaf, [
                {{{8, 5, 3}, {8, 5, 3}}, :n},
                {{{9, 7, 3}, {9, 7, 3}}, :m},
                {{{2, 2, 2}, {2, 2, 2}}, :b},
                {{{4, 9, 2}, {4, 9, 2}}, :h}
              ]}
            },
            {
              {{1, 1, 1}, {5, 7, 1}},
              {:leaf, [
                {{{5, 7, 1}, {5, 7, 1}}, :k},
                {{{5, 2, 1}, {5, 2, 1}}, :l},
                {{{1, 1, 1}, {1, 1, 1}}, :a}
              ]}
            }
          ]}
       },
       {
         {{2, 2, 3}, {7, 9, 9}},
         {:internal, [
           {
             {{3, 3, 3}, {5, 5, 5}},
             {:leaf, [
                {{{3, 3, 3}, {3, 3, 3}}, :c},
                {{{4, 4, 4}, {4, 4, 4}}, :d},
                {{{5, 5, 5}, {5, 5, 5}}, :e}
             ]}
           },
           {
             {{2, 2, 6}, {3, 9, 7}},
             {:leaf, [
                {{{3, 9, 6}, {3, 9, 6}}, :i},
                {{{2, 2, 7}, {2, 2, 7}}, :o}
             ]}
           },
           {
             {{6, 3, 3}, {7, 8, 9}},
             {:leaf, [
                {{{7, 5, 4}, {7, 5, 4}}, :p},
                {{{7, 3, 9}, {7, 3, 9}}, :j},
                {{{7, 8, 3}, {7, 8, 3}}, :g},
                {{{6, 6, 6}, {6, 6, 6}}, :f}
             ]}
           },
         ]}
       }
     ]} = new_tree

    16 = Util.count_entries(new_tree)
    true = Validation.tree_valid?(new_tree, cfg)

    {:ok, new_tree} = R.delete(new_tree, cfg, {{{2, 2, 2}, {2, 2, 2}}, :b})
    15 = Util.count_entries(new_tree)
    true = Validation.tree_valid?(new_tree, cfg)

    {:ok, new_tree} = R.delete(new_tree, cfg, {{{3, 9, 6}, {3, 9, 6}}, :i})
    14 = Util.count_entries(new_tree)
    true = Validation.tree_valid?(new_tree, cfg)
  end

  test "Delete test: remove an element from a leaf, reducing the tree to root node only" do
    cfg = %{min_entries: 2, max_entries: 4}

    delete_entry = {{{5, 39, 24}, {5, 39, 24}}, 14}
    t = {:internal,[
      {{{28, 11, 34}, {70, 89, 42}},
        {:leaf,
        [{{{70, 89, 34}, {70, 89, 34}}, 8}, {{{28, 11, 42}, {28, 11, 42}}, 13}]}},
      {{{5, 29, 24}, {56, 39, 92}},
        {:leaf,
        [{{{56, 29, 92}, {56, 29, 92}}, 15}, {{{5, 39, 24}, {5, 39, 24}}, 14}]}}
    ]}

    {:ok, nt} = R.delete(t, cfg, delete_entry)

    true = Validation.tree_valid?(nt, cfg)
  end

  test "Delete test: remove an entry from a root which is a leaf" do
    cfg = %{min_entries: 2, max_entries: 4}
    
    delete_entry = {{{49, 66, 27}, {49, 66, 27}}, 11}

    t = {:leaf,[
      {{{36, 10, 75}, {36, 10, 75}}, 2},
      {{{24, 51, 20}, {24, 51, 20}}, 18},
      {{{49, 66, 27}, {49, 66, 27}}, 11}
    ]}

    {:ok, nt} = R.delete(t, cfg, delete_entry)

    {:leaf,[
      {{{36, 10, 75}, {36, 10, 75}}, 2},
      {{{24, 51, 20}, {24, 51, 20}}, 18}
    ]} = nt 

    true = Validation.tree_valid?(nt, cfg)
  end

  test "Delete test: delete an entry whose deletion eliminates the whole subtree #0" do
    {_, cfg} = R.make(4)

    tree = {:internal,
    [
      {{{39, 76, 4}, {100, 97, 100}},
        {:internal,
        [
          {{{39, 76, 4}, {55, 77, 80}},
            {:leaf,
            [
              {{{55, 77, 4}, {55, 77, 4}}, 13}, 
              {{{39, 76, 80}, {39, 76, 80}}, 18}
            ]}},
          {{{63, 91, 28}, {100, 97, 100}},
            {:leaf,
            [
              {{{63, 97, 28}, {63, 97, 28}}, 11},
              {{{100, 91, 100}, {100, 91, 100}}, 15}
            ]}}
        ]}},
      {{{1, 21, 24}, {93, 93, 54}},
        {:internal,
        [
          {{{69, 21, 24}, {78, 72, 34}},
            {:leaf,
            [
              {{{78, 21, 34}, {78, 21, 34}}, 14}, 
              {{{69, 72, 24}, {69, 72, 24}}, 9}
            ]}},
          {{{1, 50, 51}, {93, 93, 54}},
            {:leaf,
            [
              {{{93, 93, 54}, {93, 93, 54}}, 2},
              {{{41, 58, 52}, {41, 58, 52}}, 4},
              {{{1, 50, 51}, {1, 50, 51}}, 7}
            ]}}
        ]}}
    ]}

    delete_entry = {{{78, 21, 34}, {78, 21, 34}}, 14}

    {:ok, new_tree} = R.delete(tree, cfg, delete_entry)

    true = Validation.tree_valid?(new_tree, cfg)
  end

  test "Delete test: delete an entry whose deletion eliminates the whole subtree" do
    {_, cfg} = R.make(4)

    tree = {:internal,
    [
      {{{39, 76, 4}, {100, 99, 100}},
        {:internal,
        [
          {{{42, 86, 24}, {48, 99, 36}},
            {:leaf,
            [
              {{{42, 98, 30}, {42, 98, 30}}, 6},
              {{{48, 86, 24}, {48, 86, 24}}, 17},
              {{{47, 99, 36}, {47, 99, 36}}, 19}
            ]}},
          {{{39, 76, 4}, {55, 77, 80}},
            {:leaf,
            [{{{55, 77, 4}, {55, 77, 4}}, 13}, {{{39, 76, 80}, {39, 76, 80}}, 18}]}},
          {{{63, 91, 28}, {100, 97, 100}},
            {:leaf,
            [
              {{{63, 97, 28}, {63, 97, 28}}, 11},
              {{{100, 91, 100}, {100, 91, 100}}, 15}
            ]}}
        ]}},
      {{{1, 21, 24}, {93, 93, 54}},
        {:internal,
        [
          {{{69, 21, 24}, {78, 72, 34}},
            {:leaf,
            [{{{78, 21, 34}, {78, 21, 34}}, 14}, {{{69, 72, 24}, {69, 72, 24}}, 9}]}},
          {{{1, 50, 51}, {93, 93, 54}},
            {:leaf,
            [
              {{{93, 93, 54}, {93, 93, 54}}, 2},
              {{{41, 58, 52}, {41, 58, 52}}, 4},
              {{{1, 50, 51}, {1, 50, 51}}, 7}
            ]}}
        ]}},
      {{{2, 3, 3}, {42, 46, 97}},
        {:internal,
        [
          {{{2, 27, 3}, {7, 46, 67}},
            {:leaf,
            [{{{2, 27, 67}, {2, 27, 67}}, 12}, {{{7, 46, 3}, {7, 46, 3}}, 8}]}},
          {{{18, 3, 45}, {42, 17, 97}},
            {:leaf,
            [
              {{{18, 4, 52}, {18, 4, 52}}, 16},
              {{{18, 3, 57}, {18, 3, 57}}, 5},
              {{{35, 16, 45}, {35, 16, 45}}, 1},
              {{{42, 17, 97}, {42, 17, 97}}, 3}
            ]}}
        ]}}
    ]}

    delete_entry = {{{78, 21, 34}, {78, 21, 34}}, 14}

    {:ok, new_tree} = R.delete(tree, cfg, delete_entry)

    true = Validation.tree_valid?(new_tree, cfg)
  end

  test "Delete test: case #3" do
    {_, cfg} = R.make(4)

    tree = {:internal,
      [
        {{{15, 19, 3}, {48, 36, 79}},
        {:leaf,
          [
            {{{15, 36, 11}, {15, 36, 11}}, 1},
            {{{43, 19, 79}, {43, 19, 79}}, 9},
            {{{48, 19, 3}, {48, 19, 3}}, 11}
          ]}},
        {{{67, 15, 27}, {98, 85, 30}},
        {:leaf,
          [
            {{{98, 37, 30}, {98, 37, 30}}, 18},
            {{{74, 85, 27}, {74, 85, 27}}, 13},
            {{{67, 15, 30}, {67, 15, 30}}, 5}
          ]}},
        {{{38, 9, 3}, {94, 51, 83}},
        {:leaf,
          [
            {{{38, 22, 3}, {38, 22, 3}}, 4},
            {{{94, 31, 63}, {94, 31, 63}}, 19},
            {{{59, 9, 22}, {59, 9, 22}}, 8},
            {{{58, 51, 83}, {58, 51, 83}}, 7}
          ]}}
      ]}

    delete_entry = {{{38, 22, 3}, {38, 22, 3}}, 4}
    {:ok, new_tree} = R.delete(tree, cfg, delete_entry)

    true = Validation.tree_valid?(new_tree, cfg)
  end

  @tag :long_running
  @tag :long_running_delete
  test "Delete test: over 9000" do
    single_run = fn () ->
        n = 20
        entries =
        1..n
        |> Enum.map(fn i ->
            m = 100
            loc = {:rand.uniform(m), :rand.uniform(m), :rand.uniform(m)}
            {i, loc}
        end)
        |> Util.points2entries

        {tree, cfg} = R.make(4)
        {:ok, tree} = R.insert(tree, cfg, entries)
        true = Validation.tree_valid?(tree, cfg)

        entries
        |> Enum.take_random(:rand.uniform(n))
        |> Enum.with_index
        |> Enum.reduce({tree, cfg}, fn {e, i}, {t, c} ->
          expected_count = n - i - 1

          try do
            {:ok, nt} = R.delete(t, c, e)
            ^expected_count = Util.count_entries(nt)
            true = Validation.tree_valid?(nt, cfg)

            {nt, c}
          rescue 
            RuntimeError ->
              IO.inspect e, [pretty: true, limit: 10000000]
              IO.inspect t, [pretty: true, limit: 10000000]
              # IO.inspect nt

              raise "Ooops..."

            MatchError ->
              IO.inspect e, [pretty: true, limit: 10000000]
              IO.inspect t, [pretty: true, limit: 10000000]

              raise "ooopsasa"

            FunctionClauseError ->
              IO.inspect e, [pretty: true, limit: 10000000]
              IO.inspect t, [pretty: true, limit: 10000000]

              raise "FunctionClauseError"
              
          end
        end)
      end

    1..100
    |> Enum.each(fn _ -> single_run.() end)
  end
end