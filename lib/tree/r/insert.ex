defmodule Tesseract.Tree.R.Insert do
  alias Tesseract.Geometry.Box
  alias Tesseract.Tree.R.Util
  alias Tesseract.Tree.R.Split
  alias Tesseract.Ext.EnumExt

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
    {:internal, [Util.internal_entry(node1), Util.internal_entry(node2)]}
  end

  defp insert_entry({:leaf, leaf_entries}, cfg, new_entry) do
    [new_entry | leaf_entries]
    |> post_insert(cfg, :leaf)
  end

  defp insert_entry({:internal, entries}, cfg, new_entry) do
    entries
    |> insert_entry_into_subtree(cfg, new_entry)
    |> post_insert(cfg, :internal)
  end

  defp insert_entry_into_subtree(entries, cfg, {new_entry_mbb, _} = new_entry) do
    {{_, chosen_node}, index} = choose_insert_entry(entries, new_entry)

    case insert_entry(chosen_node, cfg, new_entry) do
      {:ok, {_, [_ | _]} = child_node} ->
        List.replace_at(entries, index, Util.internal_entry(child_node))

      {:split, {child_node1, child_node2}} ->
        entries = List.delete_at(entries, index)
        [Util.internal_entry(child_node1) | [Util.internal_entry(child_node2) | entries]]
    end
  end

  def insert_entry_at(root, cfg, entry, entry_depth) do
    new_root = 
      insert_entry_at(root, cfg, entry, entry_depth, 0)
      |> normalize_insert
    
    {:ok, new_root}
  end

  def insert_entry_at({:internal, entries}, cfg, entry, entry_depth, depth) when depth == entry_depth do
    [entry | entries]
    |> post_insert(cfg, :internal)
  end

  def insert_entry_at({:internal, entries}, cfg, entry, entry_depth, depth) do
    {{_, chosen_node}, index} = choose_insert_entry(entries, entry)

    new_entries = case insert_entry_at(chosen_node, cfg, entry, entry_depth, depth + 1) do
      {:ok, child_node} ->
        List.replace_at(entries, index, Util.internal_entry(child_node))

      {:split, {child_node1, child_node2}} ->
        entries = List.delete_at(entries, index)
        [Util.internal_entry(child_node1) | [Util.internal_entry(child_node2) | entries]]
    end
    
    new_entries
    |> post_insert(cfg, :internal)
  end

  defp choose_insert_entry(entries, {new_entry_mbb, _}) do
    EnumExt.min_with_index(
      entries,
      fn {entry_mbb, _} ->
        Box.volume_increase(entry_mbb, new_entry_mbb)
      end,
      fn {entry_mbb, _} ->
        Box.volume(entry_mbb)
      end
    )
  end

  defp post_insert(entries, cfg, type) do
    if length(entries) > cfg.max_entries do
      {g1_entries, g2_entries} =
        entries
        |> Split.split(cfg)
        |> Split.unpack_split

      {:split, {{type, g1_entries}, {type, g2_entries}}}
    else
      {:ok, {type, entries}}
    end
  end
end
