defprotocol Tesseract.Tree do

  def insert(tree, record)

  def query(tree, query)

end

defprotocol Tesseract.TreeFactory do

  # TODO: move to Tesseract.Tree, implement Atom for this one
  def make(type, cfg)

  # TODO: use Tree.Record.make instead!
  def make_record(type, label, value)

end

defimpl Tesseract.TreeFactory, for: Atom do
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.MPB

  def make(type, cfg \\ [])
  def make(:tb, cfg), do: TB.make(cfg)
  def make(:mpb, cfg), do: MPB.make(cfg)

  def make_record(:tb, label, value), do: TB.Record.make(label, value)
  
  def make_record(:mpb, label, {value_start, value_end}) do
    MPB.Record.make(label, value_start, value_end)
  end

end

defimpl Tesseract.Tree, for: Tuple do
  alias Tesseract.Tree.TB
  alias Tesseract.Tree.MPB
  
  def insert({:tb_tree, _, _} = tree, record), do: TB.insert(tree, record)
  def insert({:mpb_tree, _} = tree, record), do: MPB.insert(tree, record)

  def query({:tb_tree, _, _} = tree, query_rect), do: TB.query(tree, query_rect)
  def query({:mpb_tree, _} = tree, query), do: MPB.query(tree, query)

end