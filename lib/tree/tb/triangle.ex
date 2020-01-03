defmodule Tesseract.Tree.TB.Triangle do

  # WARNING: LEVEL OF THE FIRST DECOMPOSITION IS 2, NOT 1 AS PER PAPER!

  @lambda 16

  @north 0
  @north_east 1
  @east 2
  @south_east 3
  @south 4
  @south_west 5
  @west 6
  @north_west 7

  def make({_ax, _ay} = apex_point, direction, level) 
    when (is_atom(direction) or direction >= 0 and direction <= 7) and is_integer(level) and level > 0 
  do
    {apex_point, direction |> to_direction, level} |> fix
  end

  defp fix({{_ax, _ay}, direction, level} = triangle)
    when direction >= 0 and direction <= 7 and level > 0 
  do
    vertices = compute_vertices(triangle)
    {vertices, direction, level}
  end

  defp to_direction(dir) do
    case dir do
      :north -> @north
      @north -> @north

      :north_east -> @north_east
      @north_east -> @north_east

      :east -> @east
      @east -> @east

      :south_east -> @south_east
      @south_east -> @south_east

      :south -> @south
      @south -> @south

      :south_west -> @south_west
      @south_west -> @south_west
      
      :west -> @west
      @west -> @west

      :north_west -> @north_west
      @north_west -> @north_west
    end
  end

  def vertices({{{_ax, _ay}, {_bx, _by}, {_cx, _cy}} = vertices, direction, level})
    when direction >= 0 and direction <= 7 and is_integer(level) and level > 0
  do
    vertices
  end

  defp compute_vertices({{apex_x, apex_y} = pa, apex_direction, level} = _triangle) do
    hypothenusis_length = apex_vector_length(level+1)
    isoscele_length = :math.sqrt(2) * hypothenusis_length

    case apex_direction do
      @north ->
        b = {apex_x + hypothenusis_length, apex_y - hypothenusis_length}
        c = {apex_x - hypothenusis_length, apex_y - hypothenusis_length}
        {pa, b, c}

      @north_east ->
        b = {apex_x - isoscele_length, apex_y}
        c = {apex_x, apex_y - isoscele_length}
        {pa, b, c}

      @east ->
        b = {apex_x - hypothenusis_length, apex_y + hypothenusis_length}
        c = {apex_x - hypothenusis_length, apex_y - hypothenusis_length}
        {pa, b, c}

      @south_east ->
        b = {apex_x, apex_y + isoscele_length}
        c = {apex_x - isoscele_length, apex_y}
        {pa, b, c}

      @south ->
        b = {apex_x - hypothenusis_length, apex_y + hypothenusis_length}
        c = {apex_x + hypothenusis_length, apex_y + hypothenusis_length}
        {pa, b, c}

      @south_west ->
        b = {apex_x, apex_y + isoscele_length}
        c = {apex_x + isoscele_length, apex_y}
        {pa, b, c}

      @west ->
        b = {apex_x + hypothenusis_length, apex_y + hypothenusis_length}
        c = {apex_x + hypothenusis_length, apex_y - hypothenusis_length}
        {pa, b, c}

      @north_west ->
        b = {apex_x + isoscele_length, apex_y}
        c = {apex_x, apex_y - isoscele_length}
        {pa, b, c}

      _ ->
        raise "Unhandled direction!"
    end
  end

  defp apex_vector_length(level) when level > 0 do
    @lambda * :math.pow((:math.sqrt(2) / 2), level - 1)
  end
  
  # Algorithm 1: Children apex directions of "A Triangular Decomposition Access Method for Temporal Data - TD-tree"
  def children_apex_directions({_vertices, parent_direction, _level}) do
    if 1 <= parent_direction and parent_direction <= 4 do
      {Integer.mod(parent_direction + 5, 8), parent_direction + 3}
    else
      {Integer.mod(parent_direction + 3, 8), Integer.mod(parent_direction + 5, 8)}
    end 
  end

  # Algorithm 2: Children apex directions of "A Triangular Decomposition Access Method for Temporal Data - TD-tree"
  def children_apex_position({{parent_apex, _b, _c}, parent_direction, level}) do
    sqrt2 = :math.sqrt(2)
    length = apex_vector_length(level+1)
    {pa_start, pa_end} = parent_apex

    case parent_direction do

      @north -> {pa_start, pa_end - length}

      @north_east -> {pa_start - length/sqrt2, pa_end - length/sqrt2}

      @east -> {pa_start - length, pa_end}

      @south_east -> {pa_start - length/sqrt2, pa_end + length/sqrt2}

      @south -> {pa_start, pa_end + length}

      @south_west -> {pa_start + length/sqrt2, pa_end + length/sqrt2}

      @west -> {pa_start + length, pa_end}

      @north_west -> {pa_start + length/sqrt2, pa_end - length/sqrt2}

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

  def contains_point?({{{_ax, _ay}, {_bx, _by}, {_cx, _cy}} = vertices, _direction, _level}, point) do
    contains_point?(vertices, point)
  end

  def decompose({_vertices, _apex_direction, level} = triangle) do
    child_apex = children_apex_position(triangle)

    {child_low_direction, child_high_direction} = children_apex_directions(triangle)
    
    child_low = make(child_apex, child_low_direction, level + 1)
    child_high = make(child_apex, child_high_direction, level + 1)

    {child_low, child_high}
  end
end