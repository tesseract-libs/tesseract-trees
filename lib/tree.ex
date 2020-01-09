defprotocol Tesseract.Tree do

  def make(type, cfg)

  def type(tree)

  def insert(tree, record)

  def query(tree, query, cb \\ nil)

end

defimpl Tesseract.Tree, for: Atom do
  alias Tesseract.Tree.{TB, MPB}

  def make(type, cfg \\ [])
  def make(:tb, cfg), do: TB.make(cfg)
  def make(:mpb, cfg), do: MPB.make(cfg)

  def type(_), do: raise "Not implemented"
  def insert(_, _), do: raise "Not implemented"
  def query(_, _, _), do: raise "Not implemented"
end

defimpl Tesseract.Tree, for: Tuple do
  alias Tesseract.Tree.{TB, MPB}

  def make(_, _), do: raise "Not implemented."

  def type({:tb_tree, _, _}), do: :tb
  def type({:mpb_tree, _}), do: :mpb

  def insert({:tb_tree, _, _} = tree, record), do: TB.insert(tree, record)
  def insert({:mpb_tree, _} = tree, record), do: MPB.insert(tree, record)
  
  def query(tree, query_rect, cb \\ nil)
  def query({:tb_tree, _, _} = tree, query_rect, cb), do: TB.query(tree, query_rect, cb)
  def query({:mpb_tree, _} = tree, query, _cb), do: MPB.query(tree, query)
end
