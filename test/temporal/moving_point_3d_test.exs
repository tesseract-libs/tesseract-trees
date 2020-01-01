defmodule Tesseract.Temporal.MovingPoint3DTest do
  alias Tesseract.Temporal.MovingPoint3D
  alias Tesseract.Math.Vec3

  use ExUnit.Case, async: true

  test "[MovingPoint3D] Can compute position at arbitrary t bigger than t_ref" do
    pos_ref = Vec3.make(2.0, 3.0, 0.0)
    t_ref = 3
    velocity = Vec3.make(0.2, 0.2, 0.0)

    moving_point = MovingPoint3D.make(pos_ref, t_ref, velocity)

    {x_a, y_a, z_a} = MovingPoint3D.value_at(moving_point, 8)

    assert x_a === 3.0
    assert y_a === 4.0
    assert z_a === 0.0
  end
end