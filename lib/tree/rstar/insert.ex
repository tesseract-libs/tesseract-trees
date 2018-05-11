defmodule Tesseract.Tree.RStar.Insert do
  alias Tesseract.Ext.EnumExt

  def choose_insert_entry([{_, {:leaf, _}} | _], %{type: :rstar}, {new_entry_mbb, _}) do
    # entries
    # |> EnumExt.min_with_index(
    #   fn {entry_mbb, _} ->

    #   end,
    #   fn {entry_mbb, _} ->
    #     Box.volume()
    #   end)
  end
end