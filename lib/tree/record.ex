defprotocol Tesseract.Tree.Record do
  def label(record)
end

defimpl Tesseract.Tree.Record, for: Tuple do

  def label({:tb_record, label, _}), do: label

  def label({:mpb_record, label, _}), do: label

end