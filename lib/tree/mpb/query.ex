defmodule Tesseract.Tree.MPB.Query do
  alias Tesseract.Tree.TB.Query, as: ComponentQuery

  defstruct [
    selection: nil, 
    query_type: nil, 
    input_region: nil,
    component_queries: [
      x: [], 
      y: [], 
      z: [], 
      t: []
    ]
  ]
 
  def select(:labels) do
    %__MODULE__{selection: :labels}
  end

  def select(%__MODULE__{} = query, selection) do
    %{query | selection: selection}
  end

  defp set_query_type(%__MODULE__{} = query, query_type) do
    %{query | query_type: query_type}
  end

  defp set_input_region(%__MODULE__{} = query, input_region) do
    %{query | input_region: input_region}
  end

  defp add_component_query(%__MODULE__{} = query, component, component_query) do
    cqs = [component_query | query.component_queries[component]]
    component_queries = Keyword.replace!(query.component_queries, component, cqs)
    %{query | component_queries: component_queries}
  end

  # Query region and result do not touch/overlap in any dimension.
  def disjoint(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:disjoint)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.before(qx))
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.aftr(qx))
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.before(qy))
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.aftr(qy))
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.before(qz))
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.aftr(qz))
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.before(qt))
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.aftr(qt))
  end

  # Query region and result touch in at least one dimension
  def meets(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:meets)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.meets())
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.met_by())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.meets())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.met_by())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.meets())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.met_by())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.meets())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.met_by())
  end

  # Query region and result overlap in at least one dimension
  def overlaps(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:meets)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.overlaps())
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.overlaped_by())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.overlaps())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.overlaped_by())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.overlaps())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.overlaped_by())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.overlaps())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.overlaped_by())
  end

  # Query region and result are equal in all dimensions
  def equals(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:equals)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.equals())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.equals())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.equals())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.equals())
  end

  # Query region is fully contained within a result
  def contains(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:contains)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.contains())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.contains())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.contains())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.contains())
  end

  # Queryr region fully contains a result
  def contained_by(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:contained_by)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.during())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.during())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.during())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.during())
  end

  def covers(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:covers)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.covers())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.covers())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.covers())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.covers())
  end

  def covered_by(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:covered_by)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:labels) |> ComponentQuery.covered_by())
    |> add_component_query(:y, ComponentQuery.select(:labels) |> ComponentQuery.covered_by())
    |> add_component_query(:z, ComponentQuery.select(:labels) |> ComponentQuery.covered_by())
    |> add_component_query(:t, ComponentQuery.select(:labels) |> ComponentQuery.covered_by())
  end

  # def at_time(%__MODULE__{} = query, time) do 
  # end

  # def at_position(%__MODULE__{} = query, component, value) do
  # end

  # def between_positions(%__MODULE__{} = query, component, value_min, value_max) do
  # end
end