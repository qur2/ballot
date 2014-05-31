defmodule ScoreHelper do
	defmacro __using__(_opts) do
		quote do
			@doc """
			Duplicates a thing as many times as needed and returns the resulting list.
			"""
			def duplicate(thing, times) do
				Enum.map(0..(times-1), fn _ -> thing end)
			end
		end
	end
end

ExUnit.start []
