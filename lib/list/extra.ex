defmodule List.Extra do
  @moduledoc """
  Extensions to the standard library's List module.

  """

  @doc ~S"""
  Iterates over the list and finds the first item that returns true when passed to `fun`.
  Returns that item and the list with that item removed. Stops iterating as soon as it
  finds the first match. Note that this does NOT preserve the order of the list.

  ## Examples

      iex> List.Extra.pop_first([21, 19, 4, 18, 12], fn(x) -> rem(x, 2) == 0 end)
      {:ok, 4, [19, 21, 18, 12]}

  """
  @spec pop_first(list :: [arg], fun :: (arg -> boolean), acc :: [arg]) ::
        {:ok, arg, [arg]} | {:no_match, [arg]} when arg: var
  def pop_first(list, fun, acc \\ []) do
    cond do
      list == [] ->
        {:no_match, acc}
      fun.(hd(list)) ->
        {:ok, hd(list), acc ++ tl(list)}
      true ->
        pop_first(tl(list), fun, [hd(list) | acc])
    end
  end
end
