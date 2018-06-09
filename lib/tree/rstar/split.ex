defmodule Tesseract.Tree.RStar.Split do
  alias Tesseract.Geometry
  alias Tesseract.Geometry.Box
  alias Tesseract.Tree.R.Util

  def unpack_split({{_, g1_entries}, {_, g2_entries}}) do
    {g1_entries, g2_entries}
  end

  def split(entries, cfg) do
    axis = choose_split_axis(entries, cfg)
    {g1, g2} = choose_split_index(entries, cfg, axis)

    {{Util.entries_mbb(g1), g1}, {Util.entries_mbb(g2), g2}}
  end

  defp choose_split_axis([{entry_mbb, _} | _] = entries, cfg) do
    n = Geometry.dimensions(entry_mbb)

    sorted =
      0..(n - 1)
      |> Enum.map(fn axis -> {axis_split_score(entries, cfg, axis), axis} end)
      |> List.keysort(1)

    [{_, min_axis} | _] = sorted

    min_axis
  end

  defp choose_split_index(entries, cfg, axis) do
    map_distribution = fn {g1, g2} = dist ->
      g1_mbb = g1 |> Util.entries_mbb()
      g2_mbb = g2 |> Util.entries_mbb()
      overlap = Util.box_intersection_volume(g1_mbb, [g2_mbb])
      volume = Box.volume(g1_mbb) + Box.volume(g2_mbb)

      {overlap, volume, dist}
    end

    sorted =
      axis_distributions(entries, cfg, axis)
      |> Enum.map(map_distribution)
      |> Enum.sort()

    [{_, _, best_distribution} | _] = sorted

    best_distribution
  end

  defp axis_split_score(entries, cfg, axis) do
    reduce_fn = fn {g1, g2}, sum ->
      g1_mbb = g1 |> Util.entries_mbb()
      g2_mbb = g2 |> Util.entries_mbb()

      sum + Util.mbb_margin(g1_mbb) + Util.mbb_margin(g2_mbb)
    end

    axis_distributions(entries, cfg, axis) |> Enum.reduce(0, reduce_fn)
  end

  defp axis_distributions(entries, %{min_entries: min_entries, max_entries: max_entries}, axis) do
    sorted_entries =
      entries
      |> Enum.sort(fn {mbb_a, _}, {mbb_b, _} ->
        {a_min, a_max} = mbb_a |> Util.mbb_minmax(axis)
        {b_min, b_max} = mbb_b |> Util.mbb_minmax(axis)

        cond do
          a_min < b_min -> true
          a_min == b_min -> a_max <= b_max
          true -> false
        end
      end)

    min_entries..(max_entries - min_entries + 1)
    |> Enum.map(&Enum.split(sorted_entries, &1))
  end
end
