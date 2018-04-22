defmodule Tesseract.Tree.R do
  alias Tesseract.Geometry.Box

  defdelegate query(root, query_box), to: Tesseract.Tree.R.Query
  defdelegate insert(root, cfg, entry), to: Tesseract.Tree.R.Insert
  defdelegate delete(root, cfg, entry), to: Tesseract.Tree.R.Delete

  def make(max_entries) do
    cfg = %{min_entries: trunc(max_entries/2), max_entries: max_entries}

    {{:leaf, []}, cfg}
  end

  # require IEx

  # @type point_3d :: {number, number, number}
  # # mbb = minimal bounding box
  # @type mbb :: Box.t()

  # @type internal_entry :: {mbb, internal_node | leaf_node}
  # @type leaf_entry :: {mbb, any}

  # @type root_node :: {:root, [internal_entry | leaf_entry]}
  # @type internal_node :: {:internal, [internal_entry]}
  # @type leaf_node :: {:leaf, [leaf_entry]}

  # @type r_tree_cfg :: %{min_entries: integer, max_entries: integer}
  # @type r_tree :: {root_node, r_tree_cfg}

  # @spec make(integer) :: r_tree
  # def make(max_entries) do
  #   cfg = %{min_entries: trunc(max_entries/2), max_entries: max_entries}

  #   {{:leaf, []}, cfg}
  # end

  # def search({:leaf, entries}, search_box) do
  #   entries
  #   |> Enum.filter(&search_test(&1, search_box))
  # end

  # def search({:internal, entries}, search_box) do
  #   entries
  #   |> Enum.filter(&search_test(&1, search_box))
  #   |> Enum.flat_map(fn {_, node} -> search(node, search_box) end)
  # end

  # def search({:root, entries} = root, search_box) do
  #   if root_is_leaf?(root) do
  #     search({:leaf, entries}, search_box)
  #   else
  #     search({:internal, entries}, search_box)
  #   end
  # end

  # defp search_test({mbb, _}, search_box) do
  #   Box.intersects(search_box, mbb)
  # end

  # def insert(tree, cfg, new_entries) when is_list(new_entries) do
  #   new_tree = 
  #     new_entries
  #     |> Enum.reduce(tree, fn entry, t ->
  #       {:ok, nt} = insert(t, cfg, entry)
  #       nt
  #     end)

  #   {:ok, new_tree}
  # end

  # def insert({:root, [{_, {:leaf, _}} | _] = entries}, cfg, new_entry) do
  #   insert_root_internal({:root, entries}, cfg, new_entry)
  # end

  # def insert({:root, [{_, {:internal, _}} | _] = entries}, cfg, new_entry) do
  #   insert_root_internal({:root, entries}, cfg, new_entry)
  # end

  # # Root node is a leaf node (so few entries).
  # def insert({:root, entries}, %{max_entries: max_entries}, new_entry)
  #     when length(entries) < max_entries do
  #   {:ok, {:root, [new_entry | entries]}}
  # end

  # def insert({:root, entries}, %{max_entries: max_entries} = cfg, new_entry)
  #     when length(entries) == max_entries do
  #   case insert({:leaf, entries}, cfg, new_entry) do
  #     {:ok, {:leaf, entries}} ->
  #       # Root is still a leaf node.
  #       {:ok, {:root, entries}}

  #     {:split, {leaf_node1, leaf_node2}} ->
  #       # Root is transformed into an "internal" node with two leaf nodes.
  #       {:ok,
  #        {:root,
  #         [
  #           internal_entry(leaf_node1),
  #           internal_entry(leaf_node2)
  #         ]}}

  #     _ ->
  #       raise "Something went wrong..."
  #   end
  # end

  # def insert({:leaf, leaf_entries}, %{max_entries: max_entries}, {mbb, _} = new_entry)
  #     when length(leaf_entries) < max_entries and not is_atom(mbb) do
  #   {:ok, {:leaf, [new_entry | leaf_entries]}}
  # end

  # def insert({:leaf, leaf_entries}, %{max_entries: max_entries} = cfg, new_entry)
  #     when length(leaf_entries) == max_entries do
  #   {leaf1_entries, leaf2_entries} =
  #     [new_entry | leaf_entries]
  #     |> split(cfg)
  #     |> unpack_split

  #   {:split, {{:leaf, leaf1_entries}, {:leaf, leaf2_entries}}}
  # end

  # def insert({:internal, entries}, cfg, new_entry) do
  #   entries
  #   |> insert_entry(cfg, new_entry)
  #   |> post_insert(cfg, :internal)
  # end

  # defp post_insert(entries, cfg, type) do
  #   if length(entries) > cfg.max_entries do
  #     {g1_entries, g2_entries} =
  #       entries
  #       |> split(cfg)
  #       |> unpack_split

  #     {:split, {{type, g1_entries}, {type, g2_entries}}}
  #   else
  #     {:ok, {type, entries}}
  #   end
  # end

  # defp insert_root_internal({:root, entries}, cfg, new_entry) do
  #   entries
  #   |> insert_entry(cfg, new_entry)
  #   |> post_insert(cfg, :internal)
  #   |> case do
  #     {:ok, {:internal, entries}} ->
  #       {:ok, {:root, entries}}

  #     {:split, {node1, node2}} ->
  #       {:ok, {:root, [internal_entry(node1), internal_entry(node2)]}}
  #   end
  # end

  # defp insert_entry(entries, cfg, {new_entry_mbb, _} = new_entry) do
  #   {{_, chosen_node}, index} = choose_insert_entry(entries, new_entry)

  #   case insert(chosen_node, cfg, new_entry) do
  #     {:ok, {_, [_ | _]} = child_node} ->
  #       List.replace_at(entries, index, internal_entry(child_node))

  #     {:split, {child_node1, child_node2}} ->
  #       entries = List.delete_at(entries, index)
  #       [internal_entry(child_node1) | [internal_entry(child_node2) | entries]]
  #   end
  # end

  # defp choose_insert_entry(entries, {new_entry_mbb, _}) do
  #   EnumExt.min_with_index(
  #     entries,
  #     fn {entry_mbb, _} ->
  #       Box.volume_increase(entry_mbb, new_entry_mbb)
  #     end,
  #     fn {entry_mbb, _} ->
  #       Box.volume(entry_mbb)
  #     end
  #   )
  # end

  # defp unpack_split({{_, g1_entries}, {_, g2_entries}}) do
  #   {g1_entries, g2_entries}
  # end

  # def split(entries, cfg) do
  #   split(entries, cfg, {nil, []}, {nil, []})
  # end

  # def split([], _, g1, g2) do
  #   {g1, g2}
  # end

  # def split(entries, %{min_entries: min_entries}, {_, g1_entries} = g1, g2)
  #     when length(g1_entries) + length(entries) == min_entries do
  #   g1 = Enum.reduce(entries, g1, fn entry, group -> insert_into_group(group, entry) end)

  #   {g1, g2}
  # end

  # def split(entries, %{min_entries: min_entries}, g1, {_, g2_entries} = g2)
  #     when length(g2_entries) + length(entries) == min_entries do
  #   g2 = Enum.reduce(entries, g2, fn entry, group -> insert_into_group(group, entry) end)

  #   {g1, g2}
  # end

  # def split(entries, cfg, {_, []} = g1, {_, []} = g2) do
  #   {a, b} = pick_seed_entries(entries)
  #   g1 = insert_into_group(g1, a)
  #   g2 = insert_into_group(g2, b)

  #   entries
  #   |> List.delete(a)
  #   |> List.delete(b)
  #   |> split(cfg, g1, g2)
  # end

  # def split(entries, cfg, g1, g2) do
  #   entry = pick_next_entry(entries, g1, g2)
  #   entries = List.delete(entries, entry)
  #   picked_group = pick_group(entry, g1, g2)

  #   if picked_group == g1 do
  #     split(entries, cfg, insert_into_group(g1, entry), g2)
  #   else
  #     split(entries, cfg, g1, insert_into_group(g2, entry))
  #   end
  # end

  # def pick_seed_entries(entries) when is_list(entries) do
  #   wasted_volume = fn {{mbb_a, _} = a, {mbb_b, _} = b} ->
  #     combined_mbb = Box.add(mbb_a, mbb_b)
  #     wasted_v = Box.volume(combined_mbb) - Box.volume(mbb_a) - Box.volume(mbb_b)
  #     {wasted_v, {a, b}}
  #   end

  #   # Pick seed entries
  #   pairs =
  #     for a <- entries,
  #         b <- entries,
  #         do: {a, b}

  #   pairs
  #   |> Enum.filter(fn {a, b} -> a !== b end)
  #   |> Enum.map(wasted_volume)
  #   |> Enum.max_by(fn {wv, _} -> wv end)
  #   |> elem(1)
  # end

  # defp pick_next_entry(entries, {g1_mbb, _}, {g2_mbb, _}) do
  #   wasted_volume_diff = fn {mbb, _} = entry ->
  #     mbb_volume = Box.volume(mbb)
  #     g1_wasted_volume = Box.volume(Box.add(g1_mbb, mbb)) - mbb_volume
  #     g2_wasted_volume = Box.volume(Box.add(g2_mbb, mbb)) - mbb_volume

  #     {abs(g1_wasted_volume - g2_wasted_volume), entry}
  #   end

  #   entries
  #   |> Enum.map(wasted_volume_diff)
  #   |> Enum.max_by(fn {wasted_diff, _} -> wasted_diff end)
  #   |> elem(1)
  # end

  # defp insert_into_group({nil, group_entries}, {entry_mbb, _} = entry) do
  #   {entry_mbb, [entry | group_entries]}
  # end

  # defp insert_into_group({group_mbb, group_entries}, {entry_mbb, _} = entry) do
  #   {Box.add(group_mbb, entry_mbb), [entry | group_entries]}
  # end

  # defp pick_group({entry_mbb, _}, {g1_mbb, g1_entries} = group1, {g2_mbb, g2_entries} = group2) do
  #   g1_volume_increase = Box.volume_increase(g1_mbb, entry_mbb)
  #   g2_volume_increase = Box.volume_increase(g2_mbb, entry_mbb)

  #   cond do
  #     # By minimal group MBB volume increase.
  #     g1_volume_increase < g2_volume_increase ->
  #       group1

  #     g2_volume_increase < g1_volume_increase ->
  #       group2

  #     true ->
  #       # Resolve ties by selecting the group with least volume.
  #       cond do
  #         Box.volume(g1_mbb) < Box.volume(g2_mbb) ->
  #           group1

  #         Box.volume(g2_mbb) < Box.volume(g1_mbb) ->
  #           group2

  #         true ->
  #           # Resolve ties by selecting the group with least entries.
  #           cond do
  #             length(g1_entries) < length(g2_entries) ->
  #               group1

  #             length(g2_entries) < length(g1_entries) ->
  #               group2

  #             true ->
  #               # Resolve ties by picking any.
  #               # TODO: could choose randomly.
  #               group1
  #           end
  #       end
  #   end
  # end

  # defp reinsert({:root, entries}, cfg, reinsert_entry) do
  #   case reinsert({:internal, entries}, cfg, reinsert_entry, 0) do
  #     {:ok, {:internal, new_entries}} ->
  #       {:ok, {:root, new_entries}}

  #     {:split, {node1, node2}} ->
  #       {:ok, {:root, [internal_entry(node1), internal_entry(node2)]}}
  #   end
  # end

  # defp reinsert({:internal, entries}, cfg, {entry_depth, new_entry}, depth) when depth == entry_depth do
  #   [new_entry | entries]
  #   |> post_insert(cfg, :internal)
  # end

  # defp reinsert({:internal, entries}, cfg, {entry_depth, new_entry}, depth) do
  #   {{_, chosen_node}, index} = choose_insert_entry(entries, new_entry)

  #   new_entries = case reinsert(chosen_node, cfg, {entry_depth, new_entry}, depth + 1) do
  #     {:ok, {_, [_ | _]} = child_node} ->
  #       List.replace_at(entries, index, internal_entry(child_node))

  #     {:split, {child_node1, child_node2}} ->
  #       entries = List.delete_at(entries, index)
  #       [internal_entry(child_node1) | [internal_entry(child_node2) | entries]]
  #   end

  #   new_entries
  #   |> post_insert(cfg, :internal)
  # end

  # defp reinsert_eliminated_nodes(root_node, cfg, eliminated_nodes) do
  #   leaf_entries = 
  #     eliminated_nodes
  #     |> Enum.filter(fn 
  #       {_, {:leaf, _}} -> true 
  #       _ -> false
  #     end)
  #     |> Enum.flat_map(fn {_, {:leaf, entries}} -> entries end)

  #   internal_entries = 
  #     eliminated_nodes
  #     |> Enum.filter(fn 
  #       {_, {:leaf, _}} -> false
  #       {_, {_, _}} -> true
  #       _ -> false
  #     end)
  #     |> Enum.flat_map(fn {depth, {_, entries}} -> 
  #       entries |> Enum.map(fn e -> {depth, e} end)
  #     end)

  #   {:ok, root_node} = insert(root_node, cfg, leaf_entries)

  #   root_node = 
  #     internal_entries
  #     |> Enum.reduce(root_node, fn {depth, entry} = de, tree ->
  #       {:ok, new_tree} = reinsert(tree, cfg, {depth, entry})
  #       new_tree
  #     end)

  #   {:ok, root_node}
  # end

  # def delete(node, cfg, entry, depth \\ 0)
  # def delete({:root, entries} = root, cfg, entry, depth) do
  #   result = 
  #     if root_is_leaf?(root) do
  #       case delete({:leaf, entries}, cfg, entry, depth) do
  #         {:no_match, _} ->
  #           {:root, entries}

  #         {:deleted, new_entries, []} ->
  #           {:root, new_entries}
  #       end
  #     else
  #       case delete({:internal, entries}, cfg, entry, depth + 1) do
  #         {:no_match, _} ->
  #           {:root, entries}

  #         {:deleted, {:internal, new_entries}, eliminated_nodes} ->
  #           {{:root, new_entries}, eliminated_nodes}
  #       end
  #     end

  #   new_tree = case result do
  #     {:root, entries} ->
  #       {:ok, {:root, entries}}

  #     {{:root, entries} = node, eliminated_nodes} ->
  #       reinsert_eliminated_nodes(node, cfg, eliminated_nodes)
  #   end

  #   # IEx.pry

  #   case new_tree do

  #     {:ok, {:root, [single_entry]}} ->
  #       {_, {_, entries}} = single_entry
  #       {:ok, {:root, entries}}

  #     {:ok, {:root, _}} = result ->
  #       result 

  #     _ ->
  #       raise "Ooops, something went wrong"
  #   end
  # end

  # def delete({:internal, entries} = node, cfg, {entry_mbb, _} = entry, depth) do
  #   subtree_result = delete_in_subtree(node, cfg, entry, depth)

  #   case subtree_result do
  #     nil ->
  #       # No work was done actually, just return.
  #       {:no_match, {:internal, entries}}

  #     {{subnode, index}, eliminated_nodes} ->
  #       # TODO: underflow treatment
  #       {_, subnode_entries} = subnode

  #       {new_entries, new_eliminated_nodes} = cond do
  #         length(subnode_entries) < cfg.min_entries ->
  #           {List.delete_at(entries, index), [{depth, subnode} | eliminated_nodes]}
          
  #         true ->
  #           {List.replace_at(entries, index, internal_entry(subnode)), eliminated_nodes}
  #       end

  #       {:deleted, {:internal, new_entries}, new_eliminated_nodes}
  #   end
  # end

  # def delete({:leaf, entries}, _, entry, depth) do 
  #   case Enum.find_index(entries, &(&1 == entry)) do
  #     nil ->
  #       {:no_match, {:leaf, entries}}

  #     index ->
  #       entries = List.delete_at(entries, index)

  #       {:deleted, {:leaf, entries}, []}
  #   end
  # end

  # defp delete_in_subtree({_, entries}, cfg, {entry_mbb, _} = entry, depth) do
  #   entries
  #   |> Enum.with_index
  #   |> Enum.reduce_while(nil, fn {{mbb, subnode}, index}, acc -> 
  #     if Box.intersects(entry_mbb, mbb) do
  #       case delete(subnode, cfg, entry, depth + 1) do
  #         {:no_match, _} ->
  #           {:cont, nil}

  #         {:deleted, new_subnode, eliminated_nodes} ->
  #           {:halt, {{new_subnode, index}, eliminated_nodes}}
  #       end
  #     else
  #       {:cont, nil}
  #     end
  #   end)
  # end

  # defp internal_entry({_, [_ | _] = entries} = node) do
  #   mbb =
  #     entries
  #     |> Enum.map(&elem(&1, 0))
  #     |> Box.add()

  #   {mbb, node}
  # end

  # defp root_is_leaf?({:root, [{_, {:internal, _}} | _]}), do: false
  # defp root_is_leaf?({:root, [{_, {:leaf, _}} | _]}), do: false
  # defp root_is_leaf?(_), do: true

  # def valid?({:root, _} = root, %{min_entries: min_entries} = cfg) do
  #   # Validate depth
  #   n = count_entries(root)
  #   d = depth(root)
  #   depth_valid = if n > 1, do: d <= Float.ceil(Mathx.log(n, min_entries)) - 1, else: true

  #   depth_valid && valid_by_configuration?(root, cfg)
  # end

  # defp valid_by_configuration?({:root, entries} = root, %{max_entries: max_entries} = cfg) do
  #   if root_is_leaf?(root) do
  #     length(entries) <= max_entries
  #   else
  #     children_valid = 
  #       entries
  #       |> Enum.map(&elem(&1, 1))
  #       |> Enum.all?(&valid_by_configuration?(&1, cfg))

  #     length(entries) >= 2 && children_valid
  #   end
  # end

  # defp valid_by_configuration?(node, %{min_entries: min_entries, max_entries: max_entries}) do
  #   {_, entries} = node

  #   length(entries) >= min_entries && length(entries) <= max_entries
  # end

  # def validate!({:root, _} = root, %{min_entries: min_entries} = cfg) do
  #   n = count_entries(root)
  #   d = depth(root)
  #   depth_valid = if n > 1, do: d <= Float.ceil(Mathx.log(n, min_entries)) - 1, else: true

  #   unless depth_valid do
  #     raise "Depth not valid"
  #   end

  #   validate_by_configuration!(root, cfg)
  # end

  # defp validate_by_configuration!({:root, entries} = root, %{max_entries: max_entries} = cfg) do
  #   if root_is_leaf?(root) do
  #     unless length(entries) <= max_entries do
  #      raise "root (as leaf) overflowed"
  #     end
  #   else
  #     unless length(entries) >= 2 do
  #       raise RuntimeError
  #     end

  #     entries
  #     |> Enum.map(&elem(&1, 1))
  #     |> Enum.each(&validate_by_configuration!(&1, cfg))
  #   end
  # end

  # defp validate_by_configuration!(node, %{min_entries: min_entries, max_entries: max_entries}) do
  #   {_, entries} = node

  #   unless length(entries) >= min_entries do
  #     raise "node undeflowed"
  #   end

  #   unless length(entries) <= max_entries do
  #     raise "node overflowed"
  #   end
  # end

  # def depth(tree) do
  #   tree_depth(tree, 0)
  # end

  # defp tree_depth({:root, entries} = root, d) do
  #   if root_is_leaf?(root) do
  #     tree_depth({:leaf, entries}, d)
  #   else
  #     tree_depth({:internal, entries}, d)
  #   end
  # end

  # defp tree_depth({:internal, entries}, d) do
  #   entries
  #   |> Enum.map(fn {_, node} -> tree_depth(node, d + 1) end)
  #   |> Enum.max
  # end

  # defp tree_depth({:leaf, entries}, d) do
  #   d
  # end

  # def count_entries({:leaf, entries}), do: length(entries)
  # def count_entries({_, entries}) when is_list(entries) do
  #   entries
  #   |> Enum.map(&elem(&1, 1))
  #   |> Enum.map(&count_entries/1)
  #   |> Enum.sum()
  # end
  # def count_entries(_), do: 1
end
