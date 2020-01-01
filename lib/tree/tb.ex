# Triangular decomposition binary tree

# NOTES:
# - Allen described 13 distinct interval algebra (IA) relationships that may hold between pairs of intervals (Allen 1983)

defmodule Tesseract.Tree.TB do
  alias Tesseract.Tree.TB.{Node, Triangle, Record, Util}

  # TODO: typespec!!
  def make(cfg \\ [max_records_per_node: 32]) do
    {:tb_tree, Node.make(Triangle.make({0, 16}, :north_west, 1)), cfg}
  end

  def root({:tb_tree, root, _}), do: root

  def query({:tb_tree, root, cfg} = tree, query_rect) do
    root_triangle = Node.triangle(root)
    root_triangle_vertices = Triangle.compute_vertices(root_triangle)

    if Util.node_intersects_query?(root, query_rect) do
      query_node(root, query_rect)
    else
      IO.puts "query does not intersect with root?"
      []
    end
  end

  def query_node({:tb_node, nil, nil, triangle, records}, query_rect) do
    records
    |> Enum.filter(fn record -> 
      Util.rectangle_contains_point?(query_rect, Record.interval(record)) 
    end)
  end

  def query_node({:tb_node, left, right, _, records}, query_rect) do
    results_left = if Util.node_intersects_query?(left, query_rect) do
      query_node(left, query_rect)
    else
      []
    end

    results_right = if Util.node_intersects_query?(right, query_rect) do
      query_node(right, query_rect)
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
end