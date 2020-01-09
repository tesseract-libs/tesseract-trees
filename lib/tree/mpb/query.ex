defmodule Tesseract.Tree.MPB.Query do
  alias Tesseract.Tree.TB.Query, as: ComponentQuery

  defstruct [
    ref: nil,
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
 
  defp make(selection), do: %__MODULE__{selection: selection, ref: make_ref()}

  def select(:label), do: make(:label)
  # Not yet supported.
  # def select(:geometry), do: make(:geometry)
  # def select(:record), do: make(:record)

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
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.before(qx))
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.aftr(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.before(qy))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.aftr(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.before(qz))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.aftr(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.before(qt))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.aftr(qt))
  end

  # Query region and result touch in at least one dimension
  def meets(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:meets)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.meets(qx))
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.met_by(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.meets(qy))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.met_by(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.meets(qz))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.met_by(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.meets(qt))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.met_by(qt))
  end

  # Query region and result overlap in at least one dimension
  def overlaps(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:overlaps)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.overlaps(qx))
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.overlapped_by(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.overlaps(qy))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.overlapped_by(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.overlaps(qz))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.overlapped_by(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.overlaps(qt))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.overlapped_by(qt))
  end

  # Query region and result are equal in all dimensions
  def equals(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:equals)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.equals(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.equals(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.equals(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.equals(qt))
  end

  # Query region is fully contained within a result
  def contains(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:contains)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.contains(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.contains(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.contains(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.contains(qt))
  end

  # Query region fully contains a result
  def contained_by(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:contained_by)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.during(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.during(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.during(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.during(qt))
  end

  # Query region intersects or fully contains results. Complementary to "disjoint" query type.
  def intersects(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
    query
    |> set_query_type(:intersects)
    |> set_input_region(query_region)
    |> add_component_query(:x, ComponentQuery.select(:record) |> ComponentQuery.intersects(qx))
    |> add_component_query(:y, ComponentQuery.select(:record) |> ComponentQuery.intersects(qy))
    |> add_component_query(:z, ComponentQuery.select(:record) |> ComponentQuery.intersects(qz))
    |> add_component_query(:t, ComponentQuery.select(:record) |> ComponentQuery.intersects(qt))
  end

  # def covers(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
  #   query
  #   |> set_query_type(:covers)
  #   |> set_input_region(query_region)
  #   |> add_component_query(:x, ComponentQuery.select(:label) |> ComponentQuery.covers(qx))
  #   |> add_component_query(:y, ComponentQuery.select(:label) |> ComponentQuery.covers(qy))
  #   |> add_component_query(:z, ComponentQuery.select(:label) |> ComponentQuery.covers(qz))
  #   |> add_component_query(:t, ComponentQuery.select(:label) |> ComponentQuery.covers(qt))
  # end

  # def covered_by(%__MODULE__{} = query, {qx, qy, qz, qt} = query_region) do
  #   query
  #   |> set_query_type(:covered_by)
  #   |> set_input_region(query_region)
  #   |> add_component_query(:x, ComponentQuery.select(:label) |> ComponentQuery.covered_by(qx))
  #   |> add_component_query(:y, ComponentQuery.select(:label) |> ComponentQuery.covered_by(qy))
  #   |> add_component_query(:z, ComponentQuery.select(:label) |> ComponentQuery.covered_by(qz))
  #   |> add_component_query(:t, ComponentQuery.select(:label) |> ComponentQuery.covered_by(qt))
  # end
end

defimpl Tesseract.Tree.Query, for: Tesseract.Tree.MPB.Query  do
  alias Tesseract.Tree.Record

  def ref(%Tesseract.Tree.MPB.Query{} = query), do: query.ref

  def select(%Tesseract.Tree.MPB.Query{}, []), do: []

  def select(%Tesseract.Tree.MPB.Query{} = query, records) when is_list(records) do
    case query.selection do
      :label -> Enum.map(records, &Record.label/1)
      _ -> raise "Not implemented"
      # :geometry -> Enum.map(results, fn {:mpb_record, label, interval4d} -> interval4d end)
      # :record -> results
    end
  end
end