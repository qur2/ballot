ExUnit.start

defmodule ScoreTest do
	use ExUnit.Case
	use ScoreHelper

	test "sign of positive number is 1" do
		assert Score.sign(100) == 1
	end
	test "sign of negative number is -1" do
		assert Score.sign(-3) == -1
	end
	test "sign of 0 is 0" do
		assert Score.sign(0) == 0
	end

	test "compute pair comparisons" do
		assert Score.pairs([0, 1, 2, 3]) == [1, 1, 1, 1, 1, 1]
		assert Score.pairs([3, 2, 1, 0]) == [-1, -1, -1, -1, -1, -1]
		assert Score.pairs([2, 1, 3, 0]) == [-1, 1, -1, 1, -1, -1]
	end

	test "add integers" do
		assert Score.add(2, 3) == 5
	end
	test "add list elements pair by pair" do
		assert Score.add([1, 2, 3], [3, 2, 1]) == [4, 4, 4]
	end
	test "sum list of comparison matrices" do
		assert Score.sum([[1, 2, 3], [3, 2, 1]]) == [4, 4, 4]
	end

	test "computes graphs based on a set of ballots" do
		graph = duplicate([0, 1, 2], 5) |> Score.graph
		assert graph |> Dict.values == [5, 5, 5]
		assert graph |> Dict.keys |> Enum.map(fn {i, j} -> assert i < j end)

		graph = duplicate([2, 1, 0], 3) |> Score.graph
		assert graph |> Dict.values == [3, 3, 3]
		assert graph |> Dict.keys |> Enum.map(fn {i, j} -> assert i > j end)

		graph = (duplicate([0, 1, 3], 3) ++ duplicate([2, 1, 0], 3)) |> Score.graph
		assert graph |> Dict.values == [0, 0, 0]
	end

	test "wikipedia example" do
		#   01234
		# 5 ACBED
		# 5 ADECB
		# 8 BEDAC
		# 3 CABED
		# 7 CAEBD
		# 2 CBADE
		# 7 DCEBA
		# 8 EBADC
		ballots = duplicate([0, 2, 1, 4, 3], 5)
			++ duplicate([0, 4, 3, 1, 2], 5)
			++ duplicate([3, 0, 4, 2, 1], 8)
			++ duplicate([1, 2, 0, 4, 3], 3)
			++ duplicate([1, 3, 0, 4, 2], 7)
			++ duplicate([2, 1, 0, 3, 4], 2)
			++ duplicate([4, 3, 1, 0, 2], 7)
			++ duplicate([2, 1, 4, 3, 0], 8)
		graph = ballots |> Score.graph
		assert graph |> Score.schwartz_set |> Set.to_list == [4]
	end
end
