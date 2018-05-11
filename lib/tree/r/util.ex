defmodule Tesseract.Tree.R.Util do
  alias Tesseract.Geometry.Box
  alias Tesseract.Geometry.Point3D

  def entry_mbb({mbb, _}) do
    mbb
  end

  def entry_value({_, value}) do
    value
  end

  def internal_entry({_, [_ | _] = entries} = node) do
    mbb =
      entries
      |> Enum.map(&entry_mbb/1)
      |> Box.union()

    {mbb, node}
  end

  def point2entry({label, point}, padding \\ 0) do
    {Point3D.mbb(point, padding), label}
  end

  def points2entries(points, padding \\ 0) do
    points
    |> Enum.map(&(point2entry(&1, padding)))
  end

  def depth(tree) do
    tree_depth(tree, 0)
  end

  defp tree_depth({:leaf, _}, d) do
    d
  end

  defp tree_depth({:internal, entries}, d) do
    entries
    |> Enum.map(fn {_, node} -> tree_depth(node, d + 1) end)
    |> Enum.max
  end

  def count_entries({:leaf, entries}), do: length(entries)
  def count_entries({_, entries}) when is_list(entries) do
    entries
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&count_entries/1)
    |> Enum.sum()
  end
  def count_entries(_), do: 1

  def box_volume_increase(box_a, box_b) do
    combined = Box.union(box_a, box_b)

    Box.volume(combined) - Box.volume(box_a)
  end
end