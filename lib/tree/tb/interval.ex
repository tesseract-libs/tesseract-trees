defmodule Tesseract.Tree.TB.Interval do
  # TODO: should move to Tesseract.Math?
  
  def make(s, e), do: {min(s, e), max(s, e)}

  def min({s, _}), do: s
  def max({_, e}), do: e

  # Does interval A intersect interval B?
  def intersects?({a_min, a_max}, {b_min, b_max}) do
    b_min < a_max && b_max > a_min
  end

  def is_point?({a, a}), do: true
  def is_point?(_), do: false
end