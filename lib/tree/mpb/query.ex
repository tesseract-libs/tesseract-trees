defmodule Tesseract.Tree.MPB.Query do
  defstruct [selection: nil]

  def select(%__MODULE__{} = query, selection) do
    %{query | selection: selection}
  end

  # def disjoint(%__MODULE__{} = query, ) do

  # end

  # def meets(%__MODULE__{} = query, ) do

  # end

  # def overlaps(%__MODULE__{} = query, ) do

  # end

  # def equals(%__MODULE__{} = query, ) do
 
  # end

  # def contains(%__MODULE__{} = query, ) do

  # end

  # def contained_by(%__MODULE__{} = query, ) do

  # end

  # def covers(%__MODULE__{} = query, ) do

  # end

  # def covered_by(%__MODULE__{} = query, ) do

  # end

  # def disjoint(%__MODULE__{} = query, ) do

  # end

  # def at_time(%__MODULE__{} = query, time) do 

  # end

  # def at_position(%__MODULE__{} = query, component, value) do

  # end

  # def between_positions(%__MODULE__{} = query, component, value_min, value_max) do

  # end
end