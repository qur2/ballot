defmodule Score do
	@moduledoc """
	Utilities to implement the Schulze voting method.
	See for http://en.wikipedia.org/wiki/Schulze_method more.
	"""

	@doc """
	Given a ranking, returns a comparison matrix where every element is compared
	to every other.
	"""
	def count(arr) do
		_count(arr, length(arr), 0, [])
	end
	defp _count(_, n, i, counts) when n == i do
		counts
	end
	defp _count(arr, n, i, counts) when n > i do
		# Head is the current element, tail contains the rest.
		[h | t] = arr
		# Compare head to every other element.
		# First elem is [0] for the elem against himself.
		# Ties count for 0.
		c = [0] ++ Enum.map(t, fn(x) -> if h < x do 1 else 0 end end)
		# Recursively call the function on the tail to which we append the head
		# in order to simulate a circular list.
		# Result needs to be shifted accordingly.
		_count(t ++ [h], n, i+1, counts ++ [rotate(c, n-i)])
	end
	def rotate(arr, pivot) do
		{h, t} = Enum.split(arr, pivot)
		t ++ h
	end

	def sign(n) when n > 0 do 1 end
	def sign(n) when n < 0 do -1 end
	def sign(n) when n == 0 do 0 end
	def range_sum(n, i) do
		# sum(n-i..n)
		# sum(0..n) - sum(0..n-i)
		Float.floor(n*(n-1)/2 - (n-i)*(n-i-1)/2)
	end

	@doc """
	Given a ranking, returns a comparison triangle matrix where every element
	is compared to every other.
	"""
	def pairs(ranks) do
		len = length ranks
		graph = 1..(len*2) |> Enum.map(fn(_) -> 0 end)
		_pairs(ranks, len, 0, graph)
		# |> Enum.map(fn({{s, t}, weight}) ->
		# 	if weight > 0 do
		# 		{{s, t}, weight}
		# 	else
		# 		{{t, s}, -weight}
		# 	end
		# end)
	end
	defp _pairs(_, n, i, scores) when n == i do
		scores
	end
	defp _pairs(arr, n, i, acc) when n > i do
		[h | t] = arr
		a = Enum.with_index(t) |> Enum.reduce(acc, fn {x, j}, acc ->
			inc = sign(h-x)
			IO.puts "n=#{n}, i=#{i}, j=#{j}, index=#{range_sum(n, i)+j}"
			if inc != 0 do
				# index for upper triangle matrix
				arc_update(acc, range_sum(n, i)+j, sign(x-h))
				# for the record, index in the lower triangle matrix works as:
				# range_sum(n-1, j)+i-1
			else
				acc
			end
		end)
		_pairs(t, n, i+1, a)
	end
	def arc_update(graph, i, inc) do
		{k, [h|t]} = Enum.split(graph, i)
		k ++ [h+inc|t]
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
	def sum(counts) do
		Enum.reduce(counts, fn(count, acc) -> add(count, acc) end)
	end
end
