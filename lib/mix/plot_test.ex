defmodule Mix.Tasks.PlotTest do
  use Mix.Task

  alias Tesseract.Math.Vec3
  alias Tesseract.Temporal.{MovingPoint3D, BoundingRect}
  alias Tesseract.Temporal.Plot

  @impl Mix.Task
  def run(args) do
    t_ref = 0

    object1_pos = MovingPoint3D.make(Vec3.make(5.0, 2.0, 0.0), t_ref, Vec3.make(1.0, 1.0, 0.0))
    object2_pos = MovingPoint3D.make(Vec3.make(10.0, 6.0, 0.0), t_ref, Vec3.make(-1.0, -1.0, 0.0))
    bounding_rect = BoundingRect.make([object1_pos, object2_pos], t_ref)


    t_q = 3
    plot = Explot.new()
    Plot.MovingPoint3D.plot2d_at_t(plot, object1_pos, t_q, "A")
    Plot.MovingPoint3D.plot2d_at_t(plot, object2_pos, t_q, "B")
    Plot.BoundingRect.plot2d_at_t(plot, bounding_rect, t_q)
    Explot.plot_command(plot, "autoscale()")
    Explot.show(plot)

  end
end