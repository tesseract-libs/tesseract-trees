defmodule Tesseract.Tree.MPB.Record do
  alias Tesseract.Tree.TB.Interval

  def make(label, {t_start, vec3_start}, {t_end, vec3_end}) do
    x = Interval.make(vec3_start |> elem(1), vec3_end |> elem(1))
    y = Interval.make(vec3_start |> elem(2), vec3_end |> elem(2))
    z = Interval.make(vec3_start |> elem(3), vec3_end |> elem(3))
    t = Interval.make(t_start, t_end)
    
    {:mpb_record, label, {x, y, z, t}}  
  end

  def label({:mpb_record, label, _}), do: label

  def x({:mpb_record, _, {x, _y, _z, _t}}), do: x

  def y({:mpb_record, _, {_x, y, _z, _t}}), do: y

  def z({:mpb_record, _, {_x, _y, z, _t}}), do: z

  def t({:mpb_record, _, {_x, _y, _z, t}}), do: t
end