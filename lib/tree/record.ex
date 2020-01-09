defprotocol Tesseract.Tree.Record do
  def make(type, label, value)
  def label(record)
  def geometry(record)
  def select(record, query)
end

defimpl Tesseract.Tree.Record, for: Atom do
  alias Tesseract.Tree.{TB, MPB}

  def make(:tb, label, value), do: TB.Record.make(label, value)
  
  def make(:mpb, label, {value_start, value_end}) do
    MPB.Record.make(label, value_start, value_end)
  end

  def label(_), do: raise "Not implemented"

  def geometry(_), do: raise "Not implemented"

  def select(_, _), do: raise "Not implemented"
end

defimpl Tesseract.Tree.Record, for: Tuple do
  alias Tesseract.Tree.{TB, MPB}

  def make(_, _, _), do: raise "Not implemented"

  def label({:tb_record, label, _}), do: label

  def label({:mpb_record, label, _}), do: label

  def geometry({:tb_record, _, interval}), do: interval

  def geometry({:mpb_record, _, interval4d}), do: interval4d

  def select({:tb_record, _, _} = record, query), do: TB.Record.select(record, query)

  def select({:mpb_record, _, _} = record, query), do: MPB.Record.select(record, query)

end