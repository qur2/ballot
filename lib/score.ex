defmodule Score do
	@moduledoc """
	Utilities to implement the Schulze voting method.
	See for http://en.wikipedia.org/wiki/Schulze_method more.
	"""

	@doc """
	Returns the sign of the number, or 0 if number == 0.
	"""
	def sign(n) when n > 0 do 1 end
	def sign(n) when n < 0 do -1 end
	def sign(n) when n == 0 do 0 end
	def range_sum(n, i) do
		# sum(n-i..n)
		# sum(0..n) - sum(0..n-i)
		Float.floor(n*(n-1)/2 - (n-i)*(n-i-1)/2)
	end

	@doc """
	Given a ballot, returns a comparison triangle matrix where every
	element is compared to every other.
	"""
	def pairs(ballot) do
		len = length ballot
		_pairs(ballot, len, 0, [])
	end
	# to n-1 because the last call would be done with a single value anyway
	defp _pairs([h | t], n, i, acc) when i < n-1 do
		a = Enum.reduce(t, acc, fn (x), acc ->
			[sign(x-h) | acc]
		end)
		_pairs(t, n, i+1, a)
	end
	defp _pairs(_, n, i, scores) when i >= n-1 do
		Enum.reverse(scores)
	end

	@doc """
	Adds two element together. When applied to lists, it builds a new list
	by zipping the lists and adding each pair of members.
	"""
	def add(a, b) when is_integer(a) and is_integer(b) do
		a + b
	end
	def add(a, b) when is_list(a) and is_list(b) do
		# When add 2 lists, add their elementss pair by pair
		Enum.zip(a, b) |> Enum.map(fn {a, b} -> add(a, b) end)
	end

	@doc """
	Sums an array of comparison matrices.
	"""
	def sum(cmp_mat) do
		Enum.reduce(cmp_mat, fn(count, acc) -> add(count, acc) end)
	end

	@doc """
	Builds a graph using the provided comparison matrices.
	"""
	def graph(ballots) do
		n = length(Enum.at(ballots, 0)) - 1
		keys = 0..(n-1) |> Enum.flat_map(fn i ->
			(i+1)..n |> Enum.map(fn j -> {i, j} end)
		end)
		values = ballots |> Enum.map(fn b -> pairs(b) end) |> sum
		#Build the graph from keys and values + reverse negative arcs
		Enum.zip(keys, values) |> Enum.reduce(HashDict.new, fn {{i, j}, v}, g ->
			if v < 0 do
				HashDict.put(g, {j, i}, -v)
			else
				HashDict.put(g, {i, j}, v)
			end
		end)
	end

	def schwartz_set(graph) do
		# find nodes that are never a destination
		{o, d} = Enum.reduce(graph, {HashSet.new, HashSet.new}, fn {{i, j}, _}, {o, d} ->
			{HashSet.put(o, i), HashSet.put(d, j)}
		end)
		diff = HashSet.difference(o, d)
		if HashSet.size(diff) > 0 do
			diff
		else
			schwartz_set(reduce_graph(graph))
		end
	end
	def reduce_graph(graph) do
		{kmin, _} = Enum.reduce(graph, fn {{i, j}, v}, {{imin, jmin}, vmin} ->
			if v < vmin do
				{{i, j}, v}
			else
				{{imin, jmin}, vmin}
			end
		end)
		HashDict.delete(graph, kmin)
	end

	def clone(l, n) do
		Enum.map(0..(n-1), fn _ -> l end)
	end
	def wikipedia() do
		#   01234
		# 5 ACBED
		# 5 ADECB
		# 8 BEDAC
		# 3 CABED
		# 7 CAEBD
		# 2 CBADE
		# 7 DCEBA
		# 8 EBADC 
		clone([0, 2, 1, 4, 3], 5)
		++ clone([0, 4, 3, 1, 2], 5)
		++ clone([3, 0, 4, 2, 1], 8)
		++ clone([1, 2, 0, 4, 3], 3)
		++ clone([1, 3, 0, 4, 2], 7)
		++ clone([2, 1, 0, 3, 4], 2)
		++ clone([4, 3, 1, 0, 2], 7)
		++ clone([2, 1, 4, 3, 0], 8) |> graph |> schwartz_set
	end
end
