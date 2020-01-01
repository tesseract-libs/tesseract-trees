defmodule Tesseract.Tree.TB.Triangle do

  # WARNING: LEVEL OF THE FIRST DECOMPOSITION IS 2, NOT 1 AS PER PAPER!

  @lambda 16

  @north 0
  @north_west 1
  @west 2
  @south_west 3
  @south 4
  @south_east 5
  @east 6
  @north_east 7

  def make(apex_point, direction, level) do
    {apex_point, direction, level}
  end
  
  # Algorithm 1: Children apex directions of "A Triangular Decomposition Access Method for Temporal Data - TD-tree"
  def children_aprex_directions({_parent_apex, parent_direction, _level}) do
    if 1 <= parent_direction and parent_direction <= 4 do
      {Integer.mod(parent_direction + 5, 8), parent_direction + 3}
    else
      {Integer.mod(parent_direction + 3, 8), Integer.mod(parent_direction + 5, 8)}
    end 
  end

  # Algorithm 2: Children apex directions of "A Triangular Decomposition Access Method for Temporal Data - TD-tree"
  def children_apex_position({parent_apex, parent_direction, level}) do
    sqrt2 = :math.sqrt(2)
    #length = @lambda * :math.pow((sqrt2 / 2), level - 1)
    length = apex_vector_length(level)
    {pa_start, pa_end} = parent_apex

    case parent_direction do

      @north -> {pa_start, pa_end - length}

      @north_west -> {pa_start - length/sqrt2, pa_end - length/sqrt2}

      @west -> {pa_start - length, pa_end}

      @south_west -> {pa_start - length/sqrt2, pa_end + length/sqrt2}

      @south -> {pa_start, pa_end + length}

      @south_east -> {pa_start + length/sqrt2, pa_end + length/sqrt2}

      @east -> {pa_start + length, pa_end}

      @north_east -> {pa_start + length/sqrt2, pa_end - length/sqrt2}

      _ -> raise "Invalid parent direction"
    end
  end

  # https://stackoverflow.com/a/34093754/135020
  def contains_point?({{p1_x, p1_y}, {p2_x, p2_y}, {p3_x, p3_y}}, {p_x, p_y}) do
    dx = p_x - p3_x
    dy = p_y - p3_y
    dx32 = p3_x - p2_x
    dy23 = p2_y - p3_y
    d = dy23 * (p1_x - p3_x) + dx32 * (p1_y - p3_y)
    s = dy23 * dx + dx32 * dy
    t = (p3_y - p1_y) * dx + (p1_x - p3_x) * dy

    if d < 0 do
      s <= 0 && t <= 0 && s+t >= d
    else
      s >= 0 && t >= 0 && s+t <= d
    end
  end

  def contains_point?(triangle, point) do
    vertices = compute_vertices(triangle)
    contains_point?(vertices, point)
  end

  def compute_vertices({{apex_x, apex_y}, apex_direction, level}) do
    hypothenusis_length = apex_vector_length(level + 1)
    isoscele_length = :math.sqrt(2) * hypothenusis_length

    case apex_direction do
      @north ->
        nil

      @north_east ->
        b = {apex_x + isoscele_length, apex_y}
        c = {apex_x, apex_y - isoscele_length}
        {{apex_x, apex_y}, b, c}

    end
  end

  defp apex_vector_length(level) do
    @lambda * :math.pow((:math.sqrt(2) / 2), level - 1)
  end

end