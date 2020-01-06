defmodule Tesseract.Tree.MPB.QueryResult4 do
  
  def matches_all?({_, true, true, true, true}), do: true
  def matches_all?(_), do: false

  def matches_one?({_, true, _, _, _}), do: true
  def matches_one?({_, _, true, _, _}), do: true
  def matches_one?({_, _, _, true, _}), do: true
  def matches_one?({_, _, _, _, true}), do: true
  def matches_one?(_), do: false

  def mark(query_result, component) do
    case component do
      :x -> mark_x(query_result)
      :y -> mark_y(query_result)
      :z -> mark_y(query_result)
      :t -> mark_t(query_result)
      _ -> raise "Unknown component to mark"
    end
  end

  def mark_x({result, _, y, z, t}), do: {result, true, y, z, t}
  def mark_y({result, x, _, z, t}), do: {result, x, true, z, t}
  def mark_z({result, x, y, _, t}), do: {result, x, y, true, t}
  def mark_t({result, x, y, z, _}), do: {result, x, y, z, true}
end