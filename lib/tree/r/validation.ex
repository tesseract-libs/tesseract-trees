defmodule Tesseract.Tree.R.Validation do
  alias Tesseract.Tree.R.Util
  alias Tesseract.Ext.MathExt

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
    depth_valid = if n > 1, do: d <= Float.ceil(MathExt.log(n, min_entries)) - 1, else: true

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
end