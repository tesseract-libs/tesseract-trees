defmodule Tesseract.Temporal.Plot.BoundingRect do
  alias Tesseract.Geometry.AABB3
  alias Tesseract.Temporal.BoundingRect

  def plot2d_at_t(plot, bounding_rect, t) do
    {{a_x, a_y, _}, {b_x, b_y, _}} = BoundingRect.value_at(bounding_rect, t)

    Explot.plot_command(plot, "gca().add_patch(Rectangle((#{a_x}, #{a_y}), #{b_x - a_x}, #{b_y - a_y}, fill=None, alpha=1))")
  end
end