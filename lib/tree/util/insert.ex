defmodule Tesseract.Tree.Util.Insert do
  alias Tesseract.Tree

  def make_tree_from_records(type, records \\ [], cfg \\ []) do
    type
    |> Tree.make(cfg)
    |> insert_records(records)
  end

  def insert_records(tree, records) when is_list(records) do
    records
    |> Enum.reduce(tree, fn record, tree ->
        {:ok, new_tree} = Tree.insert(tree, record)
        new_tree
      end)
  end

  def make_records(type, label_value_pairs, keep_labels \\ false) do
    label_value_pairs
    |> Enum.map(fn {label, value} ->
        if keep_labels do
          {label, Tree.Record.make(type, label, value)}
        else
          Tree.Record.make(type, label, value) 
        end
      end)
  end

  def results_contain_all_records?(results, records, only_labels \\ []) do
    expected = if only_labels do
      records |> Keyword.take(only_labels) |> Keyword.values
    else
      records
    end

    MapSet.new(results) === MapSet.new(expected)
  end

end