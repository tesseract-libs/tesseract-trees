defmodule Tesseract.Tree.TB.Interval do
  
  def make(s, e), do: {min(s, e), max(s, e)}
end