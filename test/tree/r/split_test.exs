defmodule Tesseract.Tree.R.SplitTest do
  alias Tesseract.Tree.R.Split
  alias Tesseract.Tree.R.Util

  use ExUnit.Case, async: true

  test "split parallel points", _ do
    cfg = %{max_entries: 4, min_entries: 2}

    points = [
      a: {2, 9, 0},
      b: {1, 5, 0},
      c: {5, 2, 0},
      d: {8.5, 9, 0},
      e: {8, 7, 0},
      f: {9, 3, 0}
    ]

    Split.split(Util.points2entries(points), cfg)
  end

  test "split clustered points", _ do
    cfg = %{max_entries: 4, min_entries: 2}

    points = [
      a: {10, 6, 0},
      b: {2, 5, 0},
      c: {12, 6, 0},
      d: {1, 2, 0},
      e: {11, 8, 0},
      f: {5, 3, 0}
    ]

    {
      {
        {{10, 6, 0}, {12, 8, 0}},
        [
          {{{11, 8, 0}, {11, 8, 0}}, :e},
          {{{12, 6, 0}, {12, 6, 0}}, :c},
          {{{10, 6, 0}, {10, 6, 0}}, :a}
        ]
      },
      {
        {{1, 2, 0}, {5, 5, 0}},
        [
          {{{5, 3, 0}, {5, 3, 0}}, :f},
          {{{1, 2, 0}, {1, 2, 0}}, :d},
          {{{2, 5, 0}, {2, 5, 0}}, :b}
        ]
      }
    } = Split.split(Util.points2entries(points), cfg)
  end

  test "split clustered points (with padded mbb)", _ do
    cfg = %{max_entries: 4, min_entries: 2}

    points = [
      a: {10, 6, 0},
      b: {2, 5, 0},
      c: {12, 6, 0},
      d: {1, 2, 0},
      e: {11, 8, 0},
      f: {5, 3, 0}
    ]

    {
      {
        {{0.9, 1.9, -0.1}, {5.1, 5.1, 0.1}},
        [
          {{{1.9, 4.9, -0.1}, {2.1, 5.1, 0.1}}, :b},
          {{{4.9, 2.9, -0.1}, {5.1, 3.1, 0.1}}, :f},
          {{{0.9, 1.9, -0.1}, {1.1, 2.1, 0.1}}, :d}
        ]
      },
      {
        {{9.9, 5.9, -0.1}, {12.1, 8.1, 0.1}},
        [
          {{{9.9, 5.9, -0.1}, {10.1, 6.1, 0.1}}, :a},
          {{{11.9, 5.9, -0.1}, {12.1, 6.1, 0.1}}, :c},
          {{{10.9, 7.9, -0.1}, {11.1, 8.1, 0.1}}, :e}
        ]
      }
    } = Split.split(Util.points2entries(points, 0.1), cfg)
  end
end