defmodule Tesseract.Tree.TB.UtilTest do
  alias Tesseract.Tree.TB.Util

  use ExUnit.Case, async: true

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by rectangle, no overlap.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    rectangle = [{1, 3}, {2, 3}, {2, 4}, {1, 4}]

    assert [] === Util.sutherland_hudgman(triangle, rectangle)
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by rectangle, overlap #1.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    rectangle = [{1, 1}, {5, 1}, {5, 2}, {1, 2}]

    assert length(Util.sutherland_hudgman(triangle, rectangle)) > 0
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by rectangle, overlap #2.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    rectangle = [{4, 2}, {5, 2}, {5, 4}, {4, 4}]

    assert length(Util.sutherland_hudgman(triangle, rectangle)) > 0
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by rectangle, overlap #3.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    rectangle = [{1, 0}, {6, 0}, {6, 6}, {1, 6}]

    assert length(Util.sutherland_hudgman(triangle, rectangle)) > 0
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by a vertical line.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    line = Util.sutherland_hudgman_line(:vertical, {4, 0}, {4, 4})

    assert length(Util.sutherland_hudgman(triangle, line)) > 0
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by a horizontal line.", _ do
    triangle = [{2, 1}, {5, 1}, {3, 4}]
    line = Util.sutherland_hudgman_line(:horizontal, {2, 3}, {5, 3})

    assert length(Util.sutherland_hudgman(triangle, line)) > 0
  end

  @tag :kkk
  test "[TB-Util] Sutherland-Hudgman: triangle clipped by a vertical line which is fully contained.", _ do
    triangle = [{0, 16}, {16, 16}, {0, 0}]
    line = Util.sutherland_hudgman_line(:vertical, {1.5, 1.5}, {1.5, 2.5})

    assert length(Util.sutherland_hudgman(triangle, line)) > 0
  end

end