defmodule Tesseract.Tree.TB.Interval4D do
  

  def make_interval(s, e), do: {min(s, e), max(s, e)}

end