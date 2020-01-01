# Triangular decomposition binary tree

# NOTES:
# - Allen described 13 distinct interval algebra (IA) relationships that may hold between pairs of intervals (Allen 1983)

# TODO:
#  1.) interval-triangle containment
#  2.) split algorithm
#  3.) adding interval to a node
# TODO: make those direction module attributes!

defmodule Tesseract.Tree.TB do
  alias Tesseract.Tree.TB.{Node, Triangle, Record}

  @max_num_per_node 5

  # TODO: typespec!!
  def make() do
    {:tb_tree, Node.make(Triangle.make({0, 16}, 7, 1)), []}
  end

  def root({:tb_tree, root, _}), do: root

  def insert({:tb_tree, root, cfg}, record) do
    {:ok, {:tb_tree, insert_internal(root, record), cfg}}
  end

  defp insert_internal(root, record) do
    interval = Record.interval(record)

    cond do
      !Triangle.contains_point?(Node.triangle(root), interval) ->
        nil

      Node.is_leaf?(root) ->
        insert_into_leaf(root, record)

      true ->
        left_triangle = root |> Node.left |> Node.triangle

        if Triangle.contains_point?(left_triangle, interval) do
          Node.replace_left(root, insert_into_leaf(Node.left(root), record))
        else
          Node.replace_right(root, insert_into_leaf(Node.right(root), record))
        end
    end
  end

  def insert_into_leaf(leaf_node, record) do
    if length(Node.records(leaf_node)) < @max_num_per_node do
      Node.add_record(leaf_node, record)
    else
      IO.puts "Split split split :)"
      # split :)
    end
  end
end