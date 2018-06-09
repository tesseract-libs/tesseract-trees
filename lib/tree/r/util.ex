defmodule Tesseract.Tree.R.Util do
  alias Tesseract.Geometry.Box
  alias Tesseract.Geometry.Point3D
  alias Tesseract.Math.Vec3

  def point2entry({label, point}, padding \\ 0) do
    {Point3D.mbb(point, padding), label}
  end

  def points2entries(points, padding \\ 0) when is_list(points) do
    points |> Enum.map(&(point2entry(&1, padding)))
  end

  def entry_mbb({mbb, _}) do
    mbb
  end

  def entry_value({_, value}) do
    value
  end

  # TODO: rename to entries_mbb/1
  def union_mbb(entries) when is_list(entries) do
    entries
    |> Enum.map(&entry_mbb/1)
    |> Box.union()
  end

  # TODO: rename to wrap_mbb/1
  def internal_entry({_, [_ | _] = entries} = node) do
    {union_mbb(entries), node}
  end

  def wrap_depth(entries, depth) when is_list(entries) do
    depth
    |> List.duplicate(length(entries))
    |> Enum.zip(entries)
  end

  def wrap_depth(entry, depth) do
    {depth, entry}
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

  def box_intersection_volume(box, other_boxes) when is_list(other_boxes) do
      other_boxes
      |> Enum.map(&Box.intersection_volume(box, &1))
      |> Enum.sum
  end

  # Computes min/max coordinates along given axis
  # TODO: rename to mbb_axis_minmax (mbb_minmax could compute triple of min/max for {X, Y, Z})
  def mbb_minmax({mbb_point_a, mbb_point_b}, axis) do
    mbb_point_a_axis_value = elem(mbb_point_a, axis)
    mbb_point_b_axis_value = elem(mbb_point_b, axis)

    {
      min(mbb_point_a_axis_value, mbb_point_b_axis_value),
      max(mbb_point_a_axis_value, mbb_point_b_axis_value)
    }
  end

  # Computes a "margin" for MBB box. That is, a sum of length of all its edges.
  def mbb_margin({{x1, y1, z1} = a, {x2, y2, z2}}) do
    4 * Vec3.length(Vec3.subtract({x2, y1, z1}, a)) +
    4 * Vec3.length(Vec3.subtract({x1, y1, z2}, a)) +
    4 * Vec3.length(Vec3.subtract({x1, y2, z1}, a))
  end
end