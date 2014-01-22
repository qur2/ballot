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
	defp _count(arr, n, i, counts) when n == i do
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
		# Result needs to be shifted occordingly.
		_count(t ++ [h], n, i+1, counts ++ [Enum.slice(c, n-i..n) ++ Enum.slice(c, 0, n-i)])
	end

	@doc """
	Adds two element together. When applied to lists, it builds a new list
	by zipping the lists and adding each pair member.
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
