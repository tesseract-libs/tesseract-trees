defmodule Tesseract.Tree.TB.Util do
  alias Tesseract.Tree.TB.{Node, Triangle}

  require Logger

  @lambda 16

  def lambda(), do: @lambda

  def node_intersects_query?(node, query_rect) do
    rectangle_intersects_triangle?(query_rect, node |> Node.triangle |> Triangle.vertices)
  end

  def rectangle_intersects_triangle?(rectangle, triangle) do
    {a, b, c} = triangle
    {{min_x, min_y} = ra, {max_x, max_y} = rc} = rectangle
    
    rb = {max_x, min_y}
    rd = {min_x, max_y}

    cond do
      ra === rc ->
        # Rectangle is actually a point.
        Triangle.contains_point?(triangle, ra)

      min_x === max_x ->
        # Rectangle is actually a vertical line.
        line = sutherland_hudgman_line(:vertical, ra, rc)
        length(sutherland_hudgman(triangle, line)) > 0

      min_y === max_y ->
        # Rectangle is actually a horizontal line.
        line = sutherland_hudgman_line(:horizontal, ra, rc)
        length(sutherland_hudgman(triangle, line)) > 0

      true ->
        length(sutherland_hudgman(triangle, {ra, rb, rc, rd})) > 0
    end
  end

  def rectangle_contains_point?({{min_x, min_y}, {max_x, max_y}}, {px, py}) do
    px >= min_x && px <= max_x && py >= min_y && py <= max_y
  end

  # def make_line({a_x, a_y}, {b_x, b_y}) do
  #   k = (b_y - a_y) / ((b_x - a_x) + 0.00000001)
  #   n = a_y - k*a_x

  #   {:linear, {k, n}, {min(a_x, b_x), max(a_x, b_x)}}
  # end

  # def lines_intersect?({:linear, {k_a, n_a}, {a_min, a_max}}, {:linear, {k_b, n_b}, {b_min, b_max}}) do
  #   intersection_x = (n_b - n_a) / ((k_a - k_b) + 0.00000001)
  #   intersection_x >= a_min && intersection_x <= a_max && intersection_x >= b_min && intersection_x <= b_max
  # end

  def sutherland_hudgman_line(:vertical, {x, sy} = s, {x, ey} = e) do
    mid = (ey - sy)/2.0
    {s, {x + 0.0000000001, mid}, e}
  end

  def sutherland_hudgman_line(:horizontal, {sx, y} = s, {ex, y} = e) do
    mid = (ex - sx)/2.0
    {s, {mid, y - 0.0000000001}, e}
  end

  def sutherland_hudgman(subject_polygon, clip_polygon) when is_tuple(subject_polygon) do
    sutherland_hudgman(Tuple.to_list(subject_polygon), clip_polygon)
  end

  def sutherland_hudgman(subject_polygon, clip_polygon) when is_tuple(clip_polygon) do
    sutherland_hudgman(subject_polygon, Tuple.to_list(clip_polygon))
  end

  def sutherland_hudgman(subject_polygon, clip_polygon) do
    clip_polygon
    |> zip_reverse_neighbors
    |> Enum.reduce(subject_polygon, &sutherland_hudgman_clip_edge/2)
  end

  defp sutherland_hudgman_clip_edge({c1, c2}, input_list) do
    input_list
    |> zip_reverse_neighbors
    |> Enum.reduce({{c1, c2}, []}, &sutherland_hudgman_clip_edge_subject/2)
    |> elem(1)
  end

  defp sutherland_hudgman_clip_edge_subject({s, e}, {{c1, c2} = c, output}) do
    inside_s? = inside?(c1, c2, s)

    cond do
      inside?(c1, c2, e) ->
        output = [e | output]
        if !inside_s? do
          {c, [compute_intersection(c1, c2, s, e) | output]}
        else
          {c, output}
        end

      inside_s? ->
        {c, [compute_intersection(c1, c2, s, e) | output]}

      true ->
        {c, output}

    end
  end

  defp inside?({v1_x, v1_y}, {v2_x, v2_y}, {v_x, v_y}) do
    (v2_x - v1_x) * (v_y - v1_y) > (v2_y - v1_y) * (v_x - v1_x)
  end

  defp compute_intersection({v1_x, v1_y}, {v2_x, v2_y}, {u1_x, u1_y}, {u2_x, u2_y}) do
    dc_x = v1_x - v2_x
    dc_y = v1_y - v2_y
    dp_x = u1_x - u2_x
    dp_y = u1_y - u2_y
    n1 = v1_x * v2_y - v1_y * v2_x
    n2 = u1_x * u2_y - u1_y * u2_x
    n3 = 1.0 / (dc_x * dp_y - dc_y * dp_x)

    {(n1 * dp_x - n2 * dc_x) * n3, (n1 * dp_y - n2 * dc_y) * n3}
  end

  defp zip_reverse_neighbors(list) do
    {last, rest} = List.pop_at(list, length(list) - 1)
    List.zip([[last | rest], list])
  end
end