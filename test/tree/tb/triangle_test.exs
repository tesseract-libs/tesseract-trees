defmodule Tesseract.Tree.TB.TriangleTest do
	alias Tesseract.Tree.TB.Triangle

	use ExUnit.Case, async: true

	test "[Triangle] Correctly computes triangle vertices from apex point and apex direction for level 1." do
		# LEVEL 1
		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({0, 16}, :north_west, 1)

		assert ax === 0
		assert ay === 16
		assert round(bx) === 16
		assert round(by) === 16
		assert round(cx) === 0
		assert round(cy) === 0

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({16, 0}, :south_east, 1)
		assert ax === 16
		assert ay === 0
		assert round(bx) === 16
		assert round(by) === 16
		assert round(cx) === 0
		assert round(cy) === 0
	end

	test "[Triangle] Correctly computes triangle vertices from apex point and apex direction for level 2." do
		# LEVEL 2
		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 8}, :east, 2)
		assert ax === 8
		assert ay === 8
		assert round(bx) === 0
		assert round(by) === 16
		assert round(cx) === 0
		assert round(cy) === 0

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 8}, :south, 2)
		assert ax === 8
		assert ay === 8
		assert round(bx) === 0
		assert round(by) === 16
		assert round(cx) === 16
		assert round(cy) === 16

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 8}, :west, 2)
		assert ax === 8
		assert ay === 8
		assert round(bx) === 16
		assert round(by) === 16
		assert round(cx) === 16
		assert round(cy) === 0

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 8}, :north, 2)
		assert ax === 8
		assert ay === 8
		assert round(bx) === 16
		assert round(by) === 0
		assert round(cx) === 0
		assert round(cy) === 0
	end

	test "[Triangle] Correctly computes triangle vertices from apex point and apex direction for level 3." do
		# LEVEL 3
		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({0, 8}, :south_west, 3)
		assert ax === 0
		assert ay === 8
		assert round(bx) === 0
		assert round(by) === 16
		assert round(cx) === 8
		assert round(cy) === 8

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({0, 8}, :north_west, 3)
		assert ax === 0
		assert ay === 8
		assert round(bx) === 8
		assert round(by) === 8
		assert round(cx) === 0
		assert round(cy) === 0

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 16}, :north_east, 3)
		assert ax === 8
		assert ay === 16
		assert round(bx) === 0
		assert round(by) === 16
		assert round(cx) === 8
		assert round(cy) === 8

		{{{ax, ay}, {bx, by}, {cx, cy}}, _, _} = Triangle.make({8, 16}, :north_west, 3)
		assert ax === 8
		assert ay === 16
		assert round(bx) === 16
		assert round(by) === 16
		assert round(cx) === 8
		assert round(cy) === 8
	end

	test "[TB-Triangle] Point containment", _ do
		triangle_low = Triangle.make({8, 8}, :east, 2)
		triangle_high = Triangle.make({8, 8}, :south, 2)
		point = {10, 10}

		assert false === Triangle.contains_point?(triangle_low, point)
		assert true === Triangle.contains_point?(triangle_high, point)
	end
end