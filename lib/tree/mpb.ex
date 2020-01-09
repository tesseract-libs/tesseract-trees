defmodule Tesseract.Tree.MPB do
  alias Tesseract.Tree
  alias Tesseract.Tree.Query.TaggedResults
  alias Tesseract.Tree.MPB.{Record, Query}

  @components [:x, :y, :z, :t]

  def make(_cfg \\ []) do
    x_tree = Tree.make(:tb, [])
    y_tree = Tree.make(:tb, [])
    z_tree = Tree.make(:tb, [])
    t_tree = Tree.make(:tb, [])

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

  def query({:mpb_tree, cfg}, %Query{} = query) do
    required_tags = component_match_requirement(query)
    
    result_records = 
      @components
      |> Enum.map(fn component ->
          {{component, cfg[component]}, query.component_queries[component]}
        end)
      |> Enum.map(fn {tagged_component_tree, queries} ->
          # TODO: would be nice if we did not send the whole tree right here ;)
          Task.async(__MODULE__, :query_component, [tagged_component_tree, queries])
        end)
      |> collect_parallel_tasks
      |> List.flatten
      |> TaggedResults.match(required_tags)

    Tree.Query.select(query, result_records)
  end

  def query_component({component, component_tree}, queries) do
    queries
    |> Enum.flat_map(&query_component_single(component_tree, &1))
    # matches in at least one query.
    |> TaggedResults.match(:one)
    |> Enum.map(fn result -> {component, result} end)
  end

  def query_component_single(tree, query) do
    tree
    |> Tree.query(query)
    |> Enum.map(fn result -> {query.ref, result} end)
  end

  defp component_match_requirement(%Query{} = query) do
    case query.query_type do
      :disjoint -> :one
      :meets -> :one
      :overlaps -> {:all, @components}
      :equals -> {:all, @components}
      :contains -> {:all, @components}
      :contained_by -> {:all, @components}
      :covers -> {:all, @components}
      :covered_by -> {:all, @components}
      :intersects -> {:all, @components}
      _ -> raise "Unknown query_type"
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
        {:ok, _value} -> true
        _ -> false
      end)
    # Remove :ok tags from results
    |> Enum.map(&elem(&1, 1))
  end
end