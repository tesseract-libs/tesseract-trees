defmodule Tesseract.Tree.R.Delete do
  alias Tesseract.Tree.R.Util
  alias Tesseract.Tree.R.Insert
  alias Tesseract.Geometry.Box

  def delete(root, cfg, entry) do
    {new_root, eliminated_nodes}  = case delete_entry(root, cfg, entry, 0) do
      {:no_match, _} ->
        {root, []}

      {:deleted, new_root, eliminated_nodes} ->
        {new_root, eliminated_nodes}
    end

    {:ok, new_root} = reinsert_eliminated_nodes(new_root, cfg, eliminated_nodes)
    
    case new_root do
      {:internal, [{_, single_child_node}]} ->
        {:ok, single_child_node}

      new_root ->
        {:ok, new_root}
    end
  end
  
  defp delete_entry({:leaf, entries}, _, entry, _depth) do
    case Enum.find_index(entries, &(&1 == entry)) do
      nil ->
        {:no_match, {:leaf, entries}}

      index ->
        entries = List.delete_at(entries, index)

        {:deleted, {:leaf, entries}, []}
    end
  end

  defp delete_entry({:internal, entries} = node, cfg, entry, depth) do
    subtree_result = delete_entry_from_subtree(entries, cfg, entry, depth)

    case subtree_result do
      nil ->
        # No work was done actually, just return.
        {:no_match, node}

      {{subnode, index}, eliminated_nodes} ->
        {_, subnode_entries} = subnode

        {new_entries, new_eliminated_nodes} = cond do
          length(subnode_entries) < cfg.min_entries ->
            {List.delete_at(entries, index), [{depth + 1, subnode} | eliminated_nodes]}

          true ->
            {List.replace_at(entries, index, Util.internal_entry(subnode)), eliminated_nodes}
        end

        {:deleted, {:internal, new_entries}, new_eliminated_nodes}
    end
  end

  defp delete_entry_from_subtree(entries, cfg, {entry_mbb, _} = entry, depth) do
    entries
    |> Enum.with_index
    |> Enum.reduce_while(nil, fn {{mbb, subnode}, index}, _ -> 
      if Box.intersects(entry_mbb, mbb) do
        case delete_entry(subnode, cfg, entry, depth + 1) do
          {:no_match, _} ->
            {:cont, nil}

          {:deleted, new_subnode, eliminated_nodes} ->
            {:halt, {{new_subnode, index}, eliminated_nodes}}
        end
      else
        {:cont, nil}
      end
    end)
  end

  defp reinsert_eliminated_nodes(root_node, cfg, eliminated_nodes) do
    leaf_entries =
      eliminated_nodes
      |> Enum.filter(fn 
        {_, {:leaf, _}} -> true
        _ -> false
      end)
      |> Enum.flat_map(fn {_, {:leaf, entries}} -> entries end)

    {:ok, root_node} = Insert.insert(root_node, cfg, leaf_entries)

    root_node =
      eliminated_nodes
      |> Enum.filter(fn 
        {_, {:leaf, _}} -> false
        _ -> true
      end)
      |> Enum.flat_map(fn {depth, {_, entries}} ->
        entries |> Enum.map(fn e -> {depth, e} end)
      end)
      |> Enum.reduce(root_node, fn {depth, entry}, tree ->
        {:ok, new_tree} = Insert.insert_entry_at(tree, cfg, entry, depth)
        new_tree
      end)

    {:ok, root_node}
  end
end