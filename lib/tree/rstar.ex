defmodule Tesseract.Tree.RStar do
  defdelegate query(root, query_box), to: Tesseract.Tree.R.Query
  defdelegate insert(root, cfg, entry), to: Tesseract.Tree.RStar.Insert
  defdelegate delete(root, cfg, entry), to: Tesseract.Tree.R.Delete

  def make(max_entries) do
    cfg = %{
      min_entries: trunc(max_entries / 2),
      max_entries: max_entries,
      type: :rstar,
      reinsert_p: 0.3,
      inserter: Tesseract.Tree.RStar.Insert
    }

    {{:leaf, []}, cfg}
  end
end
