defmodule Tesseract.Tree.R.Split do
  alias Tesseract.Geometry.AABB3
  alias Tesseract.Tree.R.Util

  def unpack_split({{_, g1_entries}, {_, g2_entries}}) do
    {g1_entries, g2_entries}
  end

  def split(entries, cfg) do
    split(entries, cfg, {nil, []}, {nil, []})
  end

  def split([], _, g1, g2) do
    {g1, g2}
  end

  def split(entries, %{min_entries: min_entries}, {_, g1_entries} = g1, g2)
      when length(g1_entries) + length(entries) == min_entries do
    g1 = Enum.reduce(entries, g1, fn entry, group -> insert_into_group(group, entry) end)

    {g1, g2}
  end

  def split(entries, %{min_entries: min_entries}, g1, {_, g2_entries} = g2)
      when length(g2_entries) + length(entries) == min_entries do
    g2 = Enum.reduce(entries, g2, fn entry, group -> insert_into_group(group, entry) end)

    {g1, g2}
  end

  def split(entries, cfg, {_, []} = g1, {_, []} = g2) do
    {a, b} = pick_seed_entries(entries)
    g1 = insert_into_group(g1, a)
    g2 = insert_into_group(g2, b)

    entries
    |> List.delete(a)
    |> List.delete(b)
    |> split(cfg, g1, g2)
  end

  def split(entries, cfg, g1, g2) do
    entry = pick_next_entry(entries, g1, g2)
    entries = List.delete(entries, entry)
    picked_group = pick_group(entry, g1, g2)

    if picked_group == g1 do
      split(entries, cfg, insert_into_group(g1, entry), g2)
    else
      split(entries, cfg, g1, insert_into_group(g2, entry))
    end
  end

  def pick_seed_entries(entries) when is_list(entries) do
    wasted_volume = fn {{mbb_a, _} = a, {mbb_b, _} = b} ->
      combined_mbb = AABB3.union(mbb_a, mbb_b)
      wasted_v = AABB3.volume(combined_mbb) - AABB3.volume(mbb_a) - AABB3.volume(mbb_b)
      {wasted_v, {a, b}}
    end

    # Pick seed entries
    pairs =
      for a <- entries,
          b <- entries,
          do: {a, b}

    pairs
    |> Enum.filter(fn {a, b} -> a !== b end)
    |> Enum.map(wasted_volume)
    |> Enum.max_by(fn {wv, _} -> wv end)
    |> elem(1)
  end

  defp pick_next_entry(entries, {g1_mbb, _}, {g2_mbb, _}) do
    wasted_volume_diff = fn {mbb, _} = entry ->
      mbb_volume = AABB3.volume(mbb)
      g1_wasted_volume = AABB3.volume(AABB3.union(g1_mbb, mbb)) - mbb_volume
      g2_wasted_volume = AABB3.volume(AABB3.union(g2_mbb, mbb)) - mbb_volume

      {abs(g1_wasted_volume - g2_wasted_volume), entry}
    end

    entries
    |> Enum.map(wasted_volume_diff)
    |> Enum.max_by(fn {wasted_diff, _} -> wasted_diff end)
    |> elem(1)
  end

  defp insert_into_group({nil, group_entries}, {entry_mbb, _} = entry) do
    {entry_mbb, [entry | group_entries]}
  end

  defp insert_into_group({group_mbb, group_entries}, {entry_mbb, _} = entry) do
    {AABB3.union(group_mbb, entry_mbb) |> AABB3.fix(), [entry | group_entries]}
  end

  defp pick_group({entry_mbb, _}, {g1_mbb, g1_entries} = group1, {g2_mbb, g2_entries} = group2) do
    g1_volume_increase = Util.box_volume_increase(g1_mbb, entry_mbb)
    g2_volume_increase = Util.box_volume_increase(g2_mbb, entry_mbb)

    cond do
      # By minimal group MBB volume increase.
      g1_volume_increase < g2_volume_increase ->
        group1

      g2_volume_increase < g1_volume_increase ->
        group2

      true ->
        # Resolve ties by selecting the group with least volume.
        cond do
          AABB3.volume(g1_mbb) < AABB3.volume(g2_mbb) ->
            group1

          AABB3.volume(g2_mbb) < AABB3.volume(g1_mbb) ->
            group2

          true ->
            # Resolve ties by selecting the group with least entries.
            cond do
              length(g1_entries) < length(g2_entries) ->
                group1

              length(g2_entries) < length(g1_entries) ->
                group2

              true ->
                # Resolve ties by picking any.
                # TODO: could choose randomly.
                group1
            end
        end
    end
  end
end
