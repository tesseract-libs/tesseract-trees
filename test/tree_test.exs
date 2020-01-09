defmodule Tesseract.TreeTest do
  alias Tesseract.Tree

  use ExUnit.Case, async: true

  test "Type can be correctly resolved for all supported tree types", _ do
    assert :tb === Tree.type(Tree.make(:tb, []))
    assert :mpb === Tree.type(Tree.make(:mpb, []))
  end
end