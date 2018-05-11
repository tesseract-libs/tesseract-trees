defmodule Tesseract.Tree.RStar do
  
  def make(max_entries) do
    cfg = %{min_entries: trunc(max_entries/2), max_entries: max_entries, type: :rstar}

    {{:leaf, []}, cfg}
  end
end