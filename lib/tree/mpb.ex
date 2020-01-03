defmodule Tesseract.Tree.MPB do
  alias Tesseract.Tree
  alias Tesseract.Tree.MPB.Record
  alias Tesseract.Tree.TB

  def make(cfg \\ []) do
    x_tree = TB.make()
    y_tree = TB.make()
    z_tree = TB.make()
    t_tree = TB.make()

    {:mpb_tree, [x: x_tree, y: y_tree, z: z_tree, t: t_tree]}
  end

  def insert({:mpb_tree, cfg}, record) do
    x_tb_record = TB.Record.make(Record.label(record), Record.x(record))
    y_tb_record = TB.Record.make(Record.label(record), Record.y(record))
    z_tb_record = TB.Record.make(Record.label(record), Record.z(record))
    t_tb_record = TB.Record.make(Record.label(record), Record.t(record))
    
    cfg = Keyword.replace!(cfg, :x, Tree.insert(cfg[:x], x_tb_record))
    cfg = Keyword.replace!(cfg, :y, Tree.insert(cfg[:y], y_tb_record))
    cfg = Keyword.replace!(cfg, :z, Tree.insert(cfg[:z], z_tb_record))
    cfg = Keyword.replace!(cfg, :t, Tree.insert(cfg[:t], t_tb_record))

    {:ok, {:mpb_tree, cfg}}
  end

  def query({:mpb_tree, cfg}, {vec4_min, vec4_max} = query_box) do
    [:x, :y, :z, :t]
    |> Enum.flat_map(&query_component(cfg, query_box, &1))
    |> Enum.reduce({%{}, []},
      fn record, {hit_set, results} ->
        label = Tree.Record.label(record)
        hits = Map.get(hit_set, label, 1)
        hit_set = Map.put(hit_set, label, hits)

        if hits === 4 do
          {hit_set, [record | results]}
        else
          {hit_set, results}
        end
      end)
    |> elem(2)
  end

  defp query_component(cfg, query_box, component) do
    interval = component_query_rect(query_box, component)
    results = Tree.query(cfg[component], interval)
  end

  defp component_query_rect(query_box, component) do
    {c_min, c_max} = minmax(query_box, component)
    {{c_min, c_min}, {c_max, c_max}}
  end

  defp minmax({vec4_min, vec4_max} = _query_box, component) do
    case component do
      :x -> {vec4_min |> elem(1), vec4_max |> elem(1)}
      :y -> {vec4_min |> elem(2), vec4_max |> elem(2)}
      :z -> {vec4_min |> elem(3), vec4_max |> elem(3)}
      :t -> {vec4_min |> elem(4), vec4_max |> elem(4)}
      _ -> raise "Undefined component"
    end
  end
end