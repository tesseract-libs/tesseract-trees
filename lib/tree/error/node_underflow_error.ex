defmodule Tesseract.Tree.Error.NodeUnderflowError do
  defexception [:message]

  def exception(node: node, cfg: %{min_entries: min_entries}) do
    msg =
      "Node has underflowed. Minimum number of entries is #{min_entries}, got: \n\n #{
        inspect(node, pretty: true, limit: 10_000_000)
      }"

    %__MODULE__{message: msg}
  end
end
