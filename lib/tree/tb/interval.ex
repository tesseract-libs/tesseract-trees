defmodule Tesseract.Tree.TB.Interval do
  # TODO: should move to Tesseract.Math
  
  def make(s, e), do: {min(s, e), max(s, e)}
end