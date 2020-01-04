defmodule Tesseract.Tree.MPB do
  alias Tesseract.Tree
  alias Tesseract.TreeFactory
  alias Tesseract.Tree.MPB.Record

  require Logger

  def make(cfg \\ []) do
    x_tree = TreeFactory.make(:tb, [])
    y_tree = TreeFactory.make(:tb, [])
    z_tree = TreeFactory.make(:tb, [])
    t_tree = TreeFactory.make(:tb, [])

    {:mpb_tree, [x: x_tree, y: y_tree, z: z_tree, t: t_tree]}
  end

  def insert({:mpb_tree, cfg}, record) do
    records = [
      x: Record.to_tb_record(record, :x),
      y: Record.to_tb_record(record, :y),
      z: Record.to_tb_record(record, :z),
      t: Record.to_tb_record(record, :t)
    ]

    new_cfg =
      records
      # Make a task for each component record
      |> Enum.map(fn {component, component_record} -> 
          Task.async(__MODULE__, :insert_component, [cfg[component], component, component_record])
        end)
      |> collect_parallel_tasks

    {:ok, {:mpb_tree, new_cfg}}
  end

  def insert_component(component_tree, component, component_record) do
    {:ok, new_component_tree} = Tree.insert(component_tree, component_record)
    {component, new_component_tree}
  end

  def query({:mpb_tree, cfg}, {_vec4_min, _vec4_max} = query_region) do
    [:x, :y, :z, :t]
    # Make task for each component record
    |> Enum.map(fn component ->
        Task.async(__MODULE__, :query_component, [cfg[component], query_region, component])
      end)
    |> collect_parallel_tasks
    |> List.flatten
    # |> IO.inspect
    |> collect_query_results()
  end

  def collect_query_results(results) do
    results
    |> Enum.reduce({%{}, []},
      fn {component, record}, {component_hit_set, results} ->
        label = Tree.Record.label(record)
        # IO.puts "#{label} matches in component #{component}"
        component_hits = [{component, record} | Map.get(component_hit_set, label, [])] 
        component_hit_set = Map.put(component_hit_set, label, component_hits)

        results = if length(component_hits) === 4 do
          [component_hits | results]
        else
          results
        end

        {component_hit_set, results}
      end)
    |> elem(1)
    |> Enum.map(fn component_hits ->
        Record.make_from_tb_records(
          component_hits[:x], 
          component_hits[:y], 
          component_hits[:z],
          component_hits[:t]
        )
      end)
  end

  def query_component(component_tree, query_region, component) do
    # IO.puts "querying component #{component} with region "
    # IO.inspect query_region
    # IO.puts "query interval created for component #{component}: "

    interval = component_query_rect(query_region, component)
    # IO.inspect interval

    component_tree    
    |> Tree.query(interval)
    |> Enum.map(fn r -> {component, r} end)
  end

  defp component_query_rect(query_region, component) do
    {c_min, c_max} = minmax(query_region, component)
    {{c_min, c_min}, {c_max, c_max}}
  end

  defp minmax({vec4_min, vec4_max} = _query_region, component) do
    case component do
      :x -> {vec4_min |> elem(0), vec4_max |> elem(0)}
      :y -> {vec4_min |> elem(1), vec4_max |> elem(1)}
      :z -> {vec4_min |> elem(2), vec4_max |> elem(2)}
      :t -> {vec4_min |> elem(3), vec4_max |> elem(3)}
      _ -> raise "Undefined component"
    end
  end

  defp collect_parallel_tasks(tasks) do
    tasks
    # Wait for all components to finish.
    |> Task.yield_many(10)
    # Kill the tasks which did not return in time. TODO properly.
    |> Enum.map(fn {task, result} -> 
      result || Task.shutdown(task, :brutal_kill)
    end)
    # Filter out non-OK values
    |> Enum.filter(fn
      {:ok, value} -> 
        true

      _ = v -> 
        Logger.error("non-ok value ", [v: v])
        false
    end)
    # Remove :ok tags from results
    |> Enum.map(&elem(&1, 1))
  end
end