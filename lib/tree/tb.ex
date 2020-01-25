# TB = Triangular decomposition binary tree (a binary-tree form of TD-tree).
defmodule Tesseract.Tree.TB do
  alias Tesseract.Tree.TB.{Node, Triangle, Record, Util, Query}
  alias Tesseract.Tree

  # TODO: typespec!!
  def make(cfg \\ [max_records_per_node: 32]) do
    {:tb_tree, Node.make(Triangle.make({0, Util.lambda()}, :north_west, 1)), cfg}
  end

  def root({:tb_tree, root, _}), do: root

  def query({:tb_tree, root, cfg} = tree, %Query{query_box: query_rect} = query, cb \\ nil) do
    root_triangle = Node.triangle(root)

    if Util.node_intersects_query?(root, query_rect) do
      result_records = query_node(root, query_rect, cb)
      Tree.Query.select(query, result_records)
    else
      IO.puts "query does not intersect with root?"
      []
    end
  end

  def query_node({:tb_node, nil, nil, _triangle, records}, query_rect, cb) do
    test_predicate = fn record ->
      Util.rectangle_contains_point?(query_rect, Record.interval(record))  
    end

    cb = if is_function(cb, 2) do
      cb
    else
      fn record, acc ->
        [record | acc] 
      end
    end

    records
    |> Enum.filter(test_predicate)
    |> Enum.reduce([], cb)
  end

  def query_node({:tb_node, left, right, _, _records}, query_rect, cb) do
    results_left = if Util.node_intersects_query?(left, query_rect) do
      query_node(left, query_rect, cb)
    else
      []
    end

    results_right = if Util.node_intersects_query?(right, query_rect) do
      query_node(right, query_rect, cb)
    else
      []
    end

    results_left ++ results_right
  end

  def insert({:tb_tree, root, cfg}, record) do
    {:ok, {:tb_tree, insert_into_node(root, record, cfg), cfg}}
  end

  defp insert_into_node(root, record, cfg) do
    interval = Record.interval(record)

    cond do
      !Triangle.contains_point?(Node.triangle(root), interval) ->
        root

      Node.is_leaf?(root) ->
        insert_into_leaf(root, record, cfg)

      true ->
        left_triangle = root |> Node.left |> Node.triangle

        if Triangle.contains_point?(left_triangle, interval) do
          Node.replace_left(root, insert_into_node(Node.left(root), record, cfg))
        else
          Node.replace_right(root, insert_into_node(Node.right(root), record, cfg))
        end
    end
  end

  def insert_into_leaf(leaf_node, record, cfg) do
    if length(Node.records(leaf_node)) < cfg[:max_records_per_node] do
      Node.add_record(leaf_node, record)
    else
      split_and_insert_into_leaf(leaf_node, record, cfg)
    end
  end

  def split_and_insert_into_leaf({:tb_node, nil, nil, triangle, records}, record, cfg) do
    {child_low_triangle, child_high_triangle} = Triangle.decompose(triangle)

    node_low = Node.make(child_low_triangle)
    node_high = Node.make(child_high_triangle)

    # Distribute parent's records between newly created children.
    {node_low, node_high} =
      records
      # TODO: partition/split instead of reduce?
      |> Enum.reduce({node_low, node_high}, fn (record, {node_low, node_high}) -> 
        interval = Record.interval(record)

        if Triangle.contains_point?(Node.triangle(node_low), interval) do
          {Node.add_record(node_low, record), node_high}
        else
          {node_low, Node.add_record(node_high, record)}
        end
      end)

    new_parent_node = 
      triangle
      |> Node.make()
      |> Node.replace_left(node_low)
      |> Node.replace_right(node_high)
      |> Node.delete_records()

    # If all leaf records fall into the same newly created child, split recursively.
    cond do
      length(Node.records(node_low)) == cfg[:max_records_per_node] ->
        rec_node_low = split_and_insert_into_leaf(node_low, record, cfg)
        Node.replace_left(new_parent_node, rec_node_low)

      length(Node.records(node_high)) == cfg[:max_records_per_node] ->
        rec_node_high = split_and_insert_into_leaf(node_high, record, cfg)
        Node.replace_right(new_parent_node, rec_node_high)

      true ->
        # All fine; both newly created leaves have space for new record; choose and insert.
        if Triangle.contains_point?(Node.triangle(node_low), Record.interval(record)) do
          node_low = Node.add_record(node_low, record)
          Node.replace_left(new_parent_node, node_low)
        else
          node_high = Node.add_record(node_high, record)
          Node.replace_right(new_parent_node, node_high)
        end  
  
    end
  end

  def delete({:tb_tree, root, cfg}, descriptor) do
    {:tb_tree, delete_from_node(root, descriptor, cfg), cfg}
  end

  defp delete_from_node(root, descriptor, tree_cfg) do
    interval = Record.interval(descriptor)

    cond do
      !Triangle.contains_point?(Node.triangle(root), interval) ->
        root

      Node.is_leaf?(root) ->
        # TODO: handle leaf
        # insert_into_leaf(root, record, cfg)

      true ->
        left_triangle = root |> Node.left |> Node.triangle

        if Triangle.contains_point?(left_triangle, interval) do
          Node.replace_left(root, delete_from_node(Node.left(root), descriptor, tree_cfg))
        else
          Node.replace_right(root, delete_from_node(Node.right(root), descriptor, tree_cfg))
        end
    end
  end
  
  defp delete_from_leaf(leaf, descriptor, tree_cf)
end