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

  defp node_valid_by_configuration?({:leaf, entries}, %{
         max_entries: max_entries,
         min_entries: min_entries
       }) do
    length(entries) >= min_entries && length(entries) <= max_entries
  end

  defp node_valid_by_configuration?(
         {:internal, entries},
         %{max_entries: max_entries, min_entries: min_entries} = cfg
       ) do
    self_valid? = length(entries) >= min_entries && length(entries) <= max_entries

    children_valid? =
      entries
      |> Enum.map(&Util.entry_value/1)
      |> Enum.all?(&node_valid_by_configuration?(&1, cfg))

    self_valid? && children_valid?
  end

  def tree_valid!({:leaf, entries} = node, %{max_entries: max_entries} = cfg) do
    if length(entries) > max_entries do
      raise Tesseract.Tree.Error.NodeOverflowError, node: node, cfg: cfg
    end

    true
  end

  def tree_valid!(root, %{min_entries: min_entries} = cfg) do
    # Validate depth
    n = Util.count_entries(root)
    d = Util.depth(root)
    depth_valid = if n > 1, do: d <= Float.ceil(MathExt.log(n, min_entries)) - 1, else: true

    if not depth_valid do
      raise Tesseract.Tree.Error.DepthInvalidError, [root, d]
    end

    node_valid_by_configuration!(root, cfg)
  end

  defp node_valid_by_configuration!({:leaf, _} = node, cfg) do
    node_properties_valid!(node, cfg)
  end

  defp node_valid_by_configuration!({:internal, entries} = node, cfg) do
    true = node_properties_valid!(node, cfg)

    entries
    |> Enum.map(&Util.entry_value/1)
    |> Enum.each(&node_valid_by_configuration!(&1, cfg))
  end

  defp node_properties_valid!({_, entries} = node, cfg) do
    %{max_entries: max_entries, min_entries: min_entries} = cfg

    if length(entries) > max_entries do
      raise Tesseract.Tree.Error.NodeOverflowError, node: node, cfg: cfg
    end

    if length(entries) < min_entries do
      raise Tesseract.Tree.Error.NodeUnderflowError, node: node, cfg: cfg
    end

    true
  end
end
