defmodule Tesseract.Tree.TB.Record do
  
  def make(label, interval) do
    {:tb_record, label, interval}
  end

  def label({:tb_record, label, _}), do: label

  def interval({:tb_record, _, interval}), do: interval

end