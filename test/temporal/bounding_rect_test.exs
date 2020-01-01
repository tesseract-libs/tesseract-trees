defmodule Tesseract.Temporal.BoundingRectTest do
  alias Tesseract.Math.Vec3
  alias Tesseract.Temporal.MovingPoint3D
  alias Tesseract.Temporal.BoundingRect

  use ExUnit.Case, async: true

  test "Bounding rect can be computed for a single moving object." do
    # Moving via x-coordinate only.
    t = 2
    object_pos = MovingPoint3D.make(Vec3.make(3.0, 2.0, 6.0), t, Vec3.make(1.0, 2.0, 3.0))

    bounding_rect = BoundingRect.make([object_pos], t)

    assert bounding_rect.x_min === 3.0
    assert bounding_rect.x_max === 3.0
    assert bounding_rect.y_min === 2.0
    assert bounding_rect.y_max === 2.0
    assert bounding_rect.z_min === 6.0
    assert bounding_rect.z_max === 6.0
    assert bounding_rect.vx_min === 1.0
    assert bounding_rect.vx_max === 1.0
    assert bounding_rect.vy_min === 2.0
    assert bounding_rect.vy_max === 2.0
    assert bounding_rect.vz_min === 3.0
    assert bounding_rect.vz_max === 3.0
    assert bounding_rect.t_min === 2
    assert bounding_rect.t_max === :infinity
  end

  test "Bounding rect can be computed for multiple moving objects #1." do
    t = 2

    object1_pos = MovingPoint3D.make(Vec3.make(0.0, 0.0, 0.0), t, Vec3.make(0.2, 0.2, 0.2))
    object2_pos = MovingPoint3D.make(Vec3.make(1.0, 1.0, 1.0), t, Vec3.make(0.2, 0.2, 0.2))
    object3_pos = MovingPoint3D.make(Vec3.make(-1.0, -1.0, -1.0), t, Vec3.make(0.2, 0.2, 0.2))

    bounding_rect = BoundingRect.make([object1_pos, object2_pos, object3_pos], t)

    assert bounding_rect.x_min === -1.0
    assert bounding_rect.x_max === 1.0
    assert bounding_rect.y_min === -1.0
    assert bounding_rect.y_max === 1.0
    assert bounding_rect.z_min === -1.0
    assert bounding_rect.z_max === 1.0
    assert bounding_rect.vx_min === 0.2
    assert bounding_rect.vx_max === 0.2
    assert bounding_rect.vy_min === 0.2
    assert bounding_rect.vy_max === 0.2
    assert bounding_rect.vz_min === 0.2
    assert bounding_rect.vz_max === 0.2
    assert bounding_rect.t_min === 2
    assert bounding_rect.t_max === :infinity
  end

  test "Bounding rect can be computed for multiple moving objects #2." do
    t = 0

    object1_pos = MovingPoint3D.make(Vec3.make(5.0, 0.0, 0.0), t, Vec3.make(0.2, 0.0, 0.0))
    object2_pos = MovingPoint3D.make(Vec3.make(10.0, 0.0, 0.0), t, Vec3.make(-0.2, 0.0, 0.0))

    bounding_rect = BoundingRect.make([object1_pos, object2_pos], t)

    assert bounding_rect.x_min === 5.0
    assert bounding_rect.x_max === 10.0
    assert bounding_rect.y_min === 0.0
    assert bounding_rect.y_max === 0.0
    assert bounding_rect.z_min === 0.0
    assert bounding_rect.z_max === 0.0
    assert bounding_rect.vx_min === -0.2
    assert bounding_rect.vx_max === 0.2
    assert bounding_rect.vy_min === 0.0
    assert bounding_rect.vy_max === 0.0
    assert bounding_rect.vz_min === 0.0
    assert bounding_rect.vz_max === 0.0
    assert bounding_rect.t_min === 0
    assert bounding_rect.t_max === :infinity
  end

  @tag :kek
  test "Bounding rect can be evaluated at given time t #1" do
    t = 0

    object_pos = MovingPoint3D.make(Vec3.make(5.0, 0.0, 0.0), t, Vec3.make(0.2, 0.0, 0.0))
    bounding_rect = BoundingRect.make([object_pos], t)
    {a, b} = BoundingRect.value_at(bounding_rect, 3)

    assert {5.6, 0.0, 0.0} === a
    assert {5.6, 0.0, 0.0} === b
  end

  @tag :questionable
  test "Bounding rect can be evaluated at given time t #2" do
    t = 0

    object1_pos = MovingPoint3D.make(Vec3.make(5.0, 5.0, 0.0), t, Vec3.make(0.2, 1.0, 0.0))
    object2_pos = MovingPoint3D.make(Vec3.make(10.0, 10.0, 0.0), t, Vec3.make(-0.2, 0.0, 1.0))

    bounding_rect = BoundingRect.make([object1_pos, object2_pos], t)
    {a, b} = BoundingRect.value_at(bounding_rect, 3)

    assert {4.4, 5.0, 0.0} === a
    assert {10.6, 13.0, 3.0} === b
  end
end