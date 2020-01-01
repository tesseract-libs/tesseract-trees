defmodule Tesseract.Temporal.Plot.MovingPoint3D do
  alias Tesseract.Temporal.MovingPoint3D
  
  def plot2d_at_t(plot, moving_point, t) do
    {x, y, _} = MovingPoint3D.value_at(moving_point, t)
    {vx, vy, _} = MovingPoint3D.velocity(moving_point)
    
    Explot.plot_command(plot, "plot(#{x}, #{y}, 'bo')")
    Explot.plot_command(plot, "quiver([#{x}], [#{y}], [#{vx}], [#{vy}], width=0.005)")
  end

  def plot2d_at_t(plot, moving_point, t, label) do
    plot2d_at_t(plot, moving_point, t)

    {x, y, _} = MovingPoint3D.value_at(moving_point, t)
    Explot.plot_command(plot, "annotate(\"#{label}\", (#{x}, #{y}))")
  end
end