defmodule Score do
	@moduledoc """
	Utilities to implement the Schulze voting method.
	See http://en.wikipedia.org/wiki/Schulze_method for more.
	"""

	@doc """
	Returns the sign of the number, or 0 if number == 0.
	"""
	def sign(n) when n > 0 do 1 end
	def sign(n) when n < 0 do -1 end
	def sign(n) when n == 0 do 0 end

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
		# when adding 2 lists, add their elements pair by pair
		Enum.zip(a, b) |> Enum.map(fn {a, b} -> add(a, b) end)
	end

	@doc """
	Sums an array of comparison matrices.
	"""
	def sum(matrices) do
		Enum.reduce(matrices, fn(mat, acc) -> add(mat, acc) end)
	end

	@doc """
	Builds a graph using the provided rankings.
	The resulting graph is a hash so that:
	- A key is a directed graph arc {source, target}.
	- A value if the graph arc weight (>0).
	In case of negative score, the arc is reversed and get the absolute value
	of the score.
	"""
	def graph(ballots) do
		n = length(Enum.at(ballots, 0)) - 1
		keys = 0..(n-1) |> Enum.flat_map(fn i ->
			(i+1)..n |> Enum.map(fn j -> {i, j} end)
		end)
		values = ballots |> Enum.map(fn b -> pairs(b) end) |> sum
		# build the graph from keys and values + reverse negative arcs
		Enum.zip(keys, values) |> Enum.reduce(HashDict.new, fn {{i, j}, v}, g ->
			if v < 0 do
				HashDict.put(g, {j, i}, -v)
			else
				HashDict.put(g, {i, j}, v)
			end
		end)
	end

	@doc """
	Finds the Schwartz set in an oriented graph.
	It tries to isolate all the nodes that are never a destination (because
	they lost no duel).
	If there are no such nodes, it reduces the graph by removing the weakest
	candidate and recurse.
	"""
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

	@doc """
	Removes the weakest link from the graph.
	"""
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
end
