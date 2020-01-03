defmodule Tesseract.Tree.TB.Util do
  alias Tesseract.Tree.TB.{Node, Triangle}

  def node_intersects_query?(node, query_rect) do
    rectangle_intersects_triangle?(query_rect, node |> Node.triangle |> Triangle.vertices)
  end

  # TODO: this is expensive $$$$ :S
  def rectangle_intersects_triangle?(rectangle, triangle) do
    {a, b, c} = triangle
    {{min_x, min_y} = ra, {max_x, max_y} = rc} = rectangle
    
    rb = {max_x, min_y}
    rd = {min_x, max_y}

    easy_tests = (
      rectangle_contains_point?(rectangle, a) || 
      rectangle_contains_point?(rectangle, b) || 
      rectangle_contains_point?(rectangle, c) ||
      Triangle.contains_point?(triangle, ra) ||
      Triangle.contains_point?(triangle, rb) ||
      Triangle.contains_point?(triangle, rc) ||
      Triangle.contains_point?(triangle, rd)
    )

    if easy_tests do
      true
    else
      qa = make_line(ra, rb)
      qb = make_line(rb, rc)
      qc = make_line(rc, rd)
      qd = make_line(rd, ra)

      ta = make_line(a, b)
      tb = make_line(b, c)
      tc = make_line(c, a)

      (
        lines_intersect?(ta, qa) ||
        lines_intersect?(ta, qb) ||
        lines_intersect?(ta, qc) ||
        lines_intersect?(ta, qd) ||
        lines_intersect?(tb, qa) ||
        lines_intersect?(tb, qb) ||
        lines_intersect?(tb, qc) ||
        lines_intersect?(tb, qd) ||
        lines_intersect?(tc, qa) ||
        lines_intersect?(tc, qb) ||
        lines_intersect?(tc, qc) ||
        lines_intersect?(tc, qd)
      )
    end
  end

  def rectangle_contains_point?({{min_x, min_y}, {max_x, max_y}}, {px, py}) do
    px >= min_x && px <= max_x && py >= min_y && py <= max_y
  end

  def make_line({a_x, a_y}, {b_x, b_y}) do
    k = (b_y - a_y) / ((b_x - a_x) + 0.00000001)
    n = a_y - k*a_x

    {:linear, {k, n}, {min(a_x, b_x), max(a_x, b_x)}}
  end

  def lines_intersect?({:linear, {k_a, n_a}, {a_min, a_max}}, {:linear, {k_b, n_b}, {b_min, b_max}}) do
    intersection_x = (n_b - n_a) / ((k_a - k_b) + 0.00000001)
    intersection_x >= a_min && intersection_x <= a_max && intersection_x >= b_min && intersection_x <= b_max
  end
end