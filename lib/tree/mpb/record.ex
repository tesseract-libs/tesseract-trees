defmodule Tesseract.Tree.MPB.Record do
  alias Tesseract.Math.Interval
  alias Tesseract.Tree
  alias Tesseract.Tree.Record
  alias Tesseract.Tree.MPB.Query
  alias Tesseract.Tree.Query.SpatioTemporal

  def make(label, vec4_start, vec4_end) do
    x = Interval.make(vec4_start |> elem(0), vec4_end |> elem(0))
    y = Interval.make(vec4_start |> elem(1), vec4_end |> elem(1))
    z = Interval.make(vec4_start |> elem(2), vec4_end |> elem(2))
    t = Interval.make(vec4_start |> elem(3), vec4_end |> elem(3))
    
    {:mpb_record, label, {x, y, z, t}} 
  end

  def select({:mpb_record, label, interval} = record, %Query{:selection => selection} = _query) do
    case selection do
      :label -> label
      :geometry -> interval
      :record -> record
    end
  end

  # def select({:mpb_record, label, interval} = record, %SpatioTemporal{:selection => selection} = _query) do
  #   case selection do
  #     :label -> label
  #     :geometry -> interval
  #     :record -> record
  #   end
  # end

  def select({:tb_record, _, _}, _), do: raise "Not implemented"

  def label({:mpb_record, label, _}), do: label

  def x({:mpb_record, _, {x, _y, _z, _t}}), do: x

  def y({:mpb_record, _, {_x, y, _z, _t}}), do: y

  def z({:mpb_record, _, {_x, _y, z, _t}}), do: z

  def t({:mpb_record, _, {_x, _y, _z, t}}), do: t

  def to_tb_record({:mpb_record, label, {x, y, z, t}}, component) when is_atom(component) do
    case component do
      :x -> Tree.Record.make(:tb, label, x)
      :y -> Tree.Record.make(:tb, label, y)
      :z -> Tree.Record.make(:tb, label, z)
      :t -> Tree.Record.make(:tb, label, t)
    end
  end
end