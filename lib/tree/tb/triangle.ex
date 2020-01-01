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

  def make(apex_point, direction, level) do
    {apex_point, direction |> to_direction, level}
  end

  defp to_direction(dir) do
    case dir do
      :north -> @north
      :north_east -> @north_east
      :east -> @east
      :south_east -> @south_east
      :south -> @south
      :south_west -> @south_west
      :west -> @west
      :north_west -> @north_west
    end
  end
  
  # Algorithm 1: Children apex directions of "A Triangular Decomposition Access Method for Temporal Data - TD-tree"
  def children_apex_directions({_parent_apex, parent_direction, _level}) do
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

  def contains_point?(triangle, point) do
    vertices = compute_vertices(triangle)
    contains_point?(vertices, point)
  end

  # TODO: we _probably_ should compute and store vertices upfront! (but that's an optimization)
  def compute_vertices({{apex_x, apex_y} = pa, apex_direction, level} = t) do
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

  defp apex_vector_length(level) do
    @lambda * :math.pow((:math.sqrt(2) / 2), level - 1)
  end

  def decompose({_apex_point, _apex_direction, level} = triangle) do
    # IO.puts "Decomposing triangle:"
    # IO.inspect triangle

    child_apex = children_apex_position(triangle)
    # IO.puts "child apex:"
    # IO.inspect child_apex

    {child_low_direction, child_high_direction} = children_apex_directions(triangle)
    # IO.puts "Child directions:"
    # IO.inspect child_low_direction
    # IO.inspect child_high_direction
    
    child_low = {child_apex, child_low_direction, level + 1}
    child_high = {child_apex, child_high_direction, level + 1}
    # IO.puts "Children:"
    # IO.inspect child_low
    # IO.inspect child_high

    {child_low, child_high}
  end
end