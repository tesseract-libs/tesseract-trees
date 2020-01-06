defmodule Tesseract.Tree.MPB.QueryResult do

  def make(result, hits), do: {result, hits}
  
  def matches?({_, hits}, required_hits), do: length(hits) >= required_hits

  def matches_one?({_, []}), do: false
  def matches_one?({_, hits}) when is_list(hits), do: true

  def mark({result, hits}, component), do: {result, [component | hits]}

  def result({result, _}), do: result

end