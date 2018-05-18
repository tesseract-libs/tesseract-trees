defmodule Tesseract.Tree.R.Query do
  alias Tesseract.Geometry.Box

  def query({:leaf, entries}, query_box) do
    entries
    |> Enum.filter(&query_test(&1, query_box))
  end

  def query({:internal, entries}, query_box) do
    entries
    |> Enum.filter(&query_test(&1, query_box))
    |> Enum.flat_map(fn {_, node} -> query(node, query_box) end)
  end

  defp query_test({mbb, _}, query_box) do
    Box.intersects?(query_box, mbb)
  end
end
