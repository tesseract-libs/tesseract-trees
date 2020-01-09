defmodule Tesseract.Tree.TB.Record do
  alias Tesseract.Tree.TB.Query
  
  def make(label, interval) do
    {:tb_record, label, interval}
  end

  def label({:tb_record, label, _}), do: label

  def interval({:tb_record, _, interval}), do: interval

  def select({:tb_record, label, interval} = record, %Query{:selection => selection} = _query) do
    case selection do
      :label -> label
      :geometry -> interval
      :record -> record
    end
  end

  def select({:tb_record, _, _}, _), do: raise "Not implemented"

end