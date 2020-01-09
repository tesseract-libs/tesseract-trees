defmodule Tesseract.Tree.Query.TaggedResults do
  alias Tesseract.Tree.Record

  # Tagged results is a keyword list with tags as keys and records as values.
  
  def match(tagged_results, {:all, required_tags}) do
    all(tagged_results, required_tags)
  end

  def match(tagged_results, :one) do
    one(tagged_results)
  end

  # Returns only results which have all required tags.
  def all(tagged_results, required_tags) do
    tagged_results
    |> Enum.reduce({%{}, []}, fn {tag, result}, {candidates, matches} ->
        case add_result_tag(candidates, result, tag, required_tags) do
          {:no_match, candidates} ->
            {candidates, matches}

          {:match, new_match, candidates} ->
            {candidates, [new_match | matches]}
        end
      end)
    |> elem(1)
  end

  def one(tagged_results) do
    tagged_results
    |> Enum.reduce({MapSet.new(), []}, fn {_tag, result}, {marked, results} -> 
        label = Record.label(result)
        
        if MapSet.member?(marked, label) do
          {marked, results}                  
        else
          {MapSet.put(marked, label), [result | results]}
        end
      end)
    |> elem(1)
  end

  def add_result_tag(candidates, result, tag, required_tags) do
    required_tags = MapSet.new(required_tags)
    label = Record.label(result)

    case Map.get(candidates, label, MapSet.new()) do
      false ->
        # Result was blacklisted as a candidate, as it was already matched once.
        {:no_match, candidates}

      %MapSet{} = tags ->
        tags = MapSet.put(tags, tag)
        if tags === required_tags do
          {:match, result, Map.put(candidates, label, false)}
        else
          {:no_match, Map.put(candidates, label, tags)}
        end

      _ ->
        raise "Unknown value returned as candidate tags."
    end
  end
end