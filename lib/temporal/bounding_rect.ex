defmodule Tesseract.Temporal.BoundingRect do
  alias Tesseract.Temporal.MovingPoint3D
  alias Tesseract.Geometry.AABB3
  alias Tesseract.Math.Vec3

  defstruct x_min: 0.0,
            x_max: 0.0,
            y_min: 0.0,
            y_max: 0.0,
            z_min: 0.0,
            z_max: 0.0,
            vx_min: 0.0,
            vx_max: 0.0,
            vy_min: 0.0,
            vy_max: 0.0,
            vz_min: 0.0,
            vz_max: 0.0,
            t_min: 0,
            t_max: :infinity 

  def make(moving_objects, t) when is_list(moving_objects) do
    objects_at_t = 
      moving_objects
      |> Enum.map(&MovingPoint3D.value_at(&1, t))

    velocities =
      moving_objects
      |> Enum.map(&MovingPoint3D.velocity/1)

    %__MODULE__{
      x_min: dim_min(objects_at_t, 0),
      x_max: dim_max(objects_at_t, 0),
      y_min: dim_min(objects_at_t, 1),
      y_max: dim_max(objects_at_t, 1),
      z_min: dim_min(objects_at_t, 2),
      z_max: dim_max(objects_at_t, 2),
      vx_min: dim_min(velocities, 0),
      vx_max: dim_max(velocities, 0),
      vy_min: dim_min(velocities, 1),
      vy_max: dim_max(velocities, 1),
      vz_min: dim_min(velocities, 2),
      vz_max: dim_max(velocities, 2),
      t_min: t,
      t_max: :infinity
    }
  end

  def value_at(%__MODULE__{} = brect, t) do
    dt = t - brect.t_min

    point_min = Vec3.make(brect.x_min, brect.y_min, brect.z_min)
    point_max = Vec3.make(brect.x_max, brect.y_max, brect.z_max)
    v_min = Vec3.make(brect.vx_min, brect.vy_min, brect.vz_min)
    v_max = Vec3.make(brect.vx_max, brect.vy_max, brect.vz_max)

    AABB3.make(
      v_min |> Vec3.scale(dt) |> Vec3.add(point_min),
      v_max |> Vec3.scale(dt) |> Vec3.add(point_max)
    )
  end

  def f_area_integral(%__MODULE__{} = brect) do
    fn min, max ->
      h = min - max
      dx = brect.x_max - brect.x_min
      dy = brect.y_max - brect.y_min
      dz =  brect.z_max - brect.z_min
      dvx = brect.vx_max - brect.vx_min
      dvy = brect.vy_max - brect.vy_min
      dvz = brect.vz_max - brect.vz_min

      h*dx*dy*dz + h*h * (dx*dy*dvz + (dx*dvy + dvx*dy)*dz) / 2 +
      h*h*h * ((dx*dvy + dvx*dy)*dvz + dvx*dvy*dz) / 3 + h*h*h*h*dvx*dvy*dvz / 4
    end
  end

  def intersection(%__MODULE__{} = brect1, %__MODULE__{} = brect2) do

  end

  defp dim_min(vectors, dim) when is_list(vectors) and dim >= 0 and dim <=2 do
    vectors
    |> Enum.map(&elem(&1, dim))
    |> Enum.min()
  end

  defp dim_min(_,_), do: "Wrong arguments"

  defp dim_max(vectors, dim) when is_list(vectors) and dim >= 0 and dim <=2 do
    vectors
    |> Enum.map(&elem(&1, dim))
    |> Enum.max()
  end

  defp dim_max(_,_), do: "Wrong arguments"
end