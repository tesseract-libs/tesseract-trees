defmodule Tesseract.Tree.Error.DepthInvalidError do
  defexception [:message]

  def exception(tree: tree, actual_depth: actual_depth) do
    %__MODULE__{message: "Depth #{actual_depth} is not valid for tree: #{tree}"}
  end
end
