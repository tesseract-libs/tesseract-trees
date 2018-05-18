defmodule Tesseract.Tree.RStar.Insert do
  alias Tesseract.Ext.EnumExt
  alias Tesseract.Tree.R.Util
  alias Tesseract.Geometry.Box

  def choose_insert_entry(
        [{_, {:leaf, _}} | _] = leaf_entries,
        %{type: :rstar},
        {new_entry_mbb, _}
      ) do
    leaf_entries
    |> EnumExt.min_with_index(
      fn {_, {:leaf, value_entries}} ->
        value_mbbs = value_entries |> Enum.map(&Util.entry_mbb/1)

        Util.box_intersection_volume(new_entry_mbb, value_mbbs)
      end,
      fn {entry_mbb, _} ->
        Util.box_volume_increase(entry_mbb, new_entry_mbb)
      end
    )
  end

  def choose_insert_entry(entries, %{type: :rstar}, {new_entry_mbb, _}) do
    entries
    |> EnumExt.min_with_index(
      fn {entry_mbb, _} ->
        Util.box_volume_increase(entry_mbb, new_entry_mbb)
      end,
      fn {entry_mbb, _} ->
        Box.volume(entry_mbb)
      end
    )
  end
end
