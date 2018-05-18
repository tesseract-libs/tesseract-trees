defmodule Tesseract.Tree.Error.NodeOverflowError do
  defexception [:message]

  def exception(node: node, cfg: %{max_entries: max_entries}) do
    msg =
      "Node has overflowed. Maximum number of entries is #{max_entries}, got: #{inspect(node)}"

    %__MODULE__{message: msg}
  end
end
