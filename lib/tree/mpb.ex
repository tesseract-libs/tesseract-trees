defmodule Tesseract.Tree.MPB do
  alias Tesseract.Tree
  alias Tesseract.TreeFactory
  alias Tesseract.Tree.MPB.{Record, Query, QueryResult}

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

  def query({:mpb_tree, cfg}, %Query{} = query) do
    op = query_type_component_operator(query)
    
    [:x, :y, :z, :t]
    |> Enum.map(fn component ->
        {{component, cfg[component]}, query.component_queries[component]}
      end)
    |> Enum.map(fn {tagged_component_tree, queries} ->
        # TODO: would be nice if we did not send the whole tree right here ;)
        Task.async(__MODULE__, :query_component, [tagged_component_tree, queries])
      end)
    |> collect_parallel_tasks
    |> List.flatten
    |> match(query_type_required_matches(op)) # required matches depend on query type (1 or 4).
  end

  def query_component({component, component_tree} = c, queries) do
    queries
    |> Enum.flat_map(&query_component_single(c, &1))
    |> match(1) # matches in at least one query.
    |> Enum.map(fn result -> {component, result} end)
  end

  def query_component_single({component, component_tree}, query) do
    component_tree
    |> Tree.query(query)
    |> Enum.map(&Tree.Record.label(&1))
    |> Enum.map(fn result -> {query.ref, result} end)
  end

  ######################################################
  ## This marks the start of "absolute shitcode" block.
  ######################################################
  def match(results, nil) do
    results
    # Convert to query result set.
    |> Enum.reduce(%{}, &to_query_result_set/2)
    # Convert to list of query results.
    |> Map.values()
    # Extract just the result from the query result, producing list of results.
    |> Enum.map(&QueryResult.result/1)
  end

  def match(results, required_matches) do
    results
    # Convert to query result set.
    |> Enum.reduce(%{}, &to_query_result_set/2)
    # Convert to list of query results.
    |> Map.values()
    # **badum-tsss** Finally filtering out the ones which don't satisfy the conditions
    |> Enum.filter(&QueryResult.matches?(&1, required_matches))
    # Extract just the result from the query result, producing list of results.
    |> Enum.map(&QueryResult.result/1)
  end

  defp to_query_result_set({tag, result}, result_set) do
    qr = Map.get(result_set, result, QueryResult.make(result, []))
    qr = QueryResult.mark(qr, tag)
    Map.put(result_set, result, qr)
  end

  defp query_type_component_operator(%Query{} = query) do
    case query.query_type do
      :disjoint -> :or
      :meets -> :or
      :overlaps -> :and
      :equals -> :and
      :contains -> :and
      :contained_by -> :and
      :covers -> :and
      :covered_by -> :and
      :intersects -> :and
      _ -> raise "Unknown query_type"
    end
  end

  defp query_type_required_matches(:or), do: 1
  defp query_type_required_matches(:and), do: 4
  defp query_type_required_matches(nil), do: nil
  ####################################################
  ## This marks the end of "absolute shitcode" block.
  ####################################################

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
        false
    end)
    # Remove :ok tags from results
    |> Enum.map(&elem(&1, 1))
  end
end