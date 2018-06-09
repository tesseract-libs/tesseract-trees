defmodule Tesseract.Tree.RStar.Insert do
  alias Tesseract.Ext.EnumExt
  alias Tesseract.Geometry.AABB3
  alias Tesseract.Math.Vec3
  alias Tesseract.Tree.R.Util
  alias Tesseract.Tree.RStar.Split

  def insert(root, cfg, new_entries) when is_list(new_entries) do
    new_tree =
      new_entries
      |> Enum.reduce(root, fn entry, t ->
          insert_entry(t, cfg, entry) |> normalize_insert
      end)

    {:ok, new_tree}
  end

  defp normalize_insert({:ok, tree}) do
    tree
  end

  defp normalize_insert({:split, {node1, node2}}) do
    {:internal, [Util.wrap_mbb(node1), Util.wrap_mbb(node2)]}
  end

  defp post_insert(entries, %{} = cfg, type, depth) do
    if length(entries) > cfg.max_entries do
      overflow_treatment(entries, cfg, type, depth)
    else
      {:ok, {type, entries}}
    end
  end

  defp overflow_treatment(entries, cfg, type, depth) do
    if level_already_treated?(cfg, depth) or depth == 0 do
      # Split.
      {g1_entries, g2_entries} =
        entries
        |> Split.split(cfg)
        |> Split.unpack_split
      
      {:split, {{type, g1_entries}, {type, g2_entries}}}
    else
      # Reinsert.
      {reinsert_entries, keep_entries} = compute_reinsert_entries(entries, cfg)
      new_cfg = put_overflow_treated_level(cfg, depth)
      reinsert_entries =  Util.wrap_depth(reinsert_entries, depth)
 
      {:reinsert, {type, keep_entries}, new_cfg, reinsert_entries}
    end
  end

  defp compute_reinsert_entries(entries, %{reinsert_p: p}) do
    entries_mbb_center = AABB3.center(Util.entries_mbb(entries))

    dist = fn {entry_mbb, _} ->
      entry_mbb_center = AABB3.center(entry_mbb)
      entry_mbb_center |> Vec3.subtract(entries_mbb_center) |> Vec3.length
    end

    entries
    |> Enum.sort_by(dist, &>=/2)
    |> Enum.split(round(length(entries)*p))
  end

  defp insert_entry(node, cfg, new_entry) do
    insert_entry_at(node, cfg, new_entry, nil)
  end

  def insert_entry_at(root, cfg, entry, entry_depth) do
    case insert_entry_at(root, cfg, entry, 0, entry_depth) do
      {:reinsert, new_root, new_cfg, reinsert_entries} ->
        reinsert(new_root, new_cfg, reinsert_entries)

      insert_result ->
        {:ok, insert_result |> normalize_insert}
    end
  end

  def insert_entry_at({:leaf, entries}, cfg, entry, depth, nil) do
    [entry | entries]
    |> post_insert(cfg, :leaf, depth)
  end

  def insert_entry_at({type, entries}, cfg, entry, depth, entry_depth) when depth == entry_depth do
    [entry | entries]
    |> post_insert(cfg, type, depth)
  end

  def insert_entry_at({:internal, entries}, cfg, entry, depth, entry_depth) do
    {{_, chosen_node}, index} = entries |> choose_insert_entry(cfg, entry)

   case insert_entry_at(chosen_node, cfg, entry, depth + 1, entry_depth) do
      {:ok, child_node} ->
        new_entries = List.replace_at(entries, index, Util.wrap_mbb(child_node))
        {:ok, {:internal, new_entries}}

      {:reinsert, child_node, new_cfg, reinsert_entries} ->
        new_entries = List.replace_at(entries, index, Util.wrap_mbb(child_node))
        {:reinsert, {:internal, new_entries}, new_cfg, reinsert_entries}

      {:split, {child_node1, child_node2}} ->
        entries = List.delete_at(entries, index)
        [Util.wrap_mbb(child_node1) | [Util.wrap_mbb(child_node2) | entries]]
        |> post_insert(cfg, :internal, depth)
    end
  end

  defp reinsert(root, cfg, reinsert_entries) when is_list(reinsert_entries) do
    original_depth = Util.depth(root)

    new_root = 
      reinsert_entries
      |> Enum.reduce(root, fn {depth, entry}, tree ->
        d_incr = Util.depth(tree) - original_depth

        new_cfg = if d_incr > 0 do
          fix_overflow_treatment_depth(cfg, d_incr)
        else
          cfg
        end
        
        {:ok, new_tree} = insert_entry_at(tree, new_cfg, entry, depth + d_incr)

        new_tree
      end)

    {:ok, new_root}
  end

  def choose_insert_entry(
        [{_, {:leaf, _}} | _] = leaf_entries,
        %{type: :rstar},
        {new_entry_mbb, _}
      ) do
    leaf_entries
    |> EnumExt.min_with_index(
      fn {_, {:leaf, value_entries}} ->
        value_mbbs = value_entries |> Enum.map(&Util.entry_mbb/1)

        Util.box_intersection_volume(new_entry_mbb, value_mbbs)
      end,
      fn {entry_mbb, _} ->
        Util.box_volume_increase(entry_mbb, new_entry_mbb)
      end
    )
  end

  def choose_insert_entry(entries, %{type: :rstar}, {new_entry_mbb, _}) do
    entries
    |> EnumExt.min_with_index(
      fn {entry_mbb, _} ->
        Util.box_volume_increase(entry_mbb, new_entry_mbb)
      end,
      fn {entry_mbb, _} ->
        AABB3.volume(entry_mbb)
      end
    )
  end

  defp fix_overflow_treatment_depth(cfg, d_incr) do
    treated_levels = cfg |> Map.get(:overflow_treated_levels, %{})
    treated_levels = 
      Map.keys(treated_levels)
      |> Enum.zip(Map.values(treated_levels))
      |> Enum.map(fn {d, v} -> {d + d_incr, v} end)
      |> Enum.into(%{})

    cfg |> Map.put(:overflow_treated_levels, treated_levels)
  end

  defp put_overflow_treated_level(cfg, depth) do
    treated_levels = 
      cfg
      |> Map.get(:overflow_treated_levels, %{})
      |> Map.put(depth, true)

    cfg |> Map.put(:overflow_treated_levels, treated_levels)
  end

  defp level_already_treated?(cfg, depth) do
    cfg
    |> Map.get(:overflow_treated_levels, %{})
    |> Map.get(depth, false)
  end
end
