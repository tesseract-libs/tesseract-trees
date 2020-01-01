defmodule Tesseract.Tree.TB.Node do

  def make(triangle) do
    {:tb_node, nil, nil, triangle, []}
  end

  # TODO: typespec!!!!

  def left({:tb_node, left, _, _, _}), do: left

  def right({:tb_node, _, right, _, _}), do: right

  def replace_left({:tb_node, _, right, triangle, records}, new_left) do
    {:tb_node, new_left, right, triangle, records}
  end

  def replace_right({:tb_node, left, _, triangle, records}, new_right) do
    {:tb_node, left, new_right, triangle, records}
  end

  def triangle({:tb_node, _, _, triangle, _}), do: triangle

  def records({:tb_node, _, _, _, records}), do: records

  def add_record({:tb_node, left, right, triangle, records}, new_record) do
    {:tb_node, left, right, triangle, [new_record | records]}
  end

  def is_internal?({:tb_node, left, right, _, _}) when left != nil and right != nil, do: true
  def is_internal?(_), do: false

  def is_leaf?(node), do: !is_internal?(node)

end