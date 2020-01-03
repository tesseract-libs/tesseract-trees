defmodule Tesseract.Tree.Util.Insert do
  alias Tesseract.Tree
  alias Tesseract.TreeFactory

  def make_tree_from_records(type, records \\ [], cfg \\ []) do
    type
    |> TreeFactory.make(cfg)
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
          {label, TreeFactory.make_record(type, label, value)}
        else
          TreeFactory.make_record(type, label, value) 
        end
      end)
  end

end