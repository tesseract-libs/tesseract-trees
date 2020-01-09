defprotocol Tesseract.Tree.Query do
  def ref(query)

  def select(query, results)
end