defmodule Tesseract.Temporal.MovingPoint3D do
  alias Tesseract.Math.Vec3

  #@type t :: {Vec3.t(), Vec3.t()}

  def make(vec3_ref, t_ref, velocity_vector) do
    {vec3_ref, t_ref, velocity_vector}
  end

  def value_at({vec3_ref, t_ref, velocity_vec}, t) do
    velocity_vec
    |> Vec3.scale(t-t_ref)
    |> Vec3.add(vec3_ref)
  end

  def velocity({_, _, velocity_vec}), do: velocity_vec
end