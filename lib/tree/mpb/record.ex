defmodule Tesseract.Tree.MPB.Record do
  alias Tesseract.Tree.TB
  alias Tesseract.TreeFactory

  def make(label, vec4_start, vec4_end) do
    x = TB.Interval.make(vec4_start |> elem(0), vec4_end |> elem(0))
    y = TB.Interval.make(vec4_start |> elem(1), vec4_end |> elem(1))
    z = TB.Interval.make(vec4_start |> elem(2), vec4_end |> elem(2))
    t = TB.Interval.make(vec4_start |> elem(3), vec4_end |> elem(3))
    
    {:mpb_record, label, {x, y, z, t}} 
  end

  def make_from_tb_records(x, y, z, t) do
    label = TB.Record.label(x)
    values = {TB.Record.interval(x), TB.Record.interval(y), TB.Record.interval(z), TB.Record.interval(t)}

    {:mpb_record, label, values}
  end

  def label({:mpb_record, label, _}), do: label

  def x({:mpb_record, _, {x, _y, _z, _t}}), do: x

  def y({:mpb_record, _, {_x, y, _z, _t}}), do: y

  def z({:mpb_record, _, {_x, _y, z, _t}}), do: z

  def t({:mpb_record, _, {_x, _y, _z, t}}), do: t

  def to_tb_record({:mpb_record, label, {x, y, z, t}}, component) when is_atom(component) do
    case component do
      :x -> TreeFactory.make_record(:tb, label, x)
      :y -> TreeFactory.make_record(:tb, label, y)
      :z -> TreeFactory.make_record(:tb, label, z)
      :t -> TreeFactory.make_record(:tb, label, t)
    end
  end
end