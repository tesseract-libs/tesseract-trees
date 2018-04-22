defmodule Tesseract.Tree.R.Validation do
  alias Tesseract.Tree.R.Util

  # The rules for root being a leaf are a little bit different: 
  # A leaf node can have between MIN and MAX entries, EXCEPT when
  # leaf node is also a root node. So we have to take care of that
  # exception by having a more loose validation rule.
  def tree_valid?({:leaf, entries}, %{max_entries: max_entries}) do
    length(entries) <= max_entries
  end

  def tree_valid?(root, %{min_entries: min_entries} = cfg) do
    # Validate depth
    n = Util.count_entries(root)
    d = Util.depth(root)
    depth_valid = if n > 1, do: d <= Float.ceil(Mathx.log(n, min_entries)) - 1, else: true

    depth_valid && node_valid_by_configuration?(root, cfg)
  end

  defp node_valid_by_configuration?({:leaf, entries}, %{max_entries: max_entries, min_entries: min_entries}) do
    length(entries) >= min_entries && length(entries) <= max_entries
  end

  defp node_valid_by_configuration?({:internal, entries}, %{max_entries: max_entries, min_entries: min_entries} = cfg) do
    self_valid? = length(entries) >= min_entries && length(entries) <= max_entries
    children_valid? = 
      entries
      |> Enum.map(&Util.entry_value/1)
      |> Enum.all?(&node_valid_by_configuration?(&1, cfg))

    self_valid? && children_valid?
  end

  # def validate!({:root, _} = root, %{min_entries: min_entries} = cfg) do
  #   n = Util.count_entries(root)
  #   d = Util.depth(root)
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
end