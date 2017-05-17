defmodule Map.Extra do
  @moduledoc """
  Extensions to the standard library's Map module.

  """

  @doc """
  Runs the `func` over the map {key, values}, returning a map (`{:ok, map}`) with the same
  keys and the results of `func` for each key's value.

  Short circuits if `func` does not return {:ok, term}.

  """
  @spec each_or_error(map, (term -> {:ok, term} | {:error, reason})) ::
    {:ok, map} | {:error, reason} when reason: any
  def each_or_error(map, func) do
    Enum.into(map, [])
    |> do_each_or_error(func)
    |> case do
      result when is_list(result) ->
        map =
           Enum.into(result, %{})

        {:ok, map}

      {:error, _} = err ->
        err
    end
  end

  defp do_each_or_error(keyword, func, acc \\ [])
  defp do_each_or_error([], _func, acc), do: acc |> Enum.reverse()
  defp do_each_or_error([{key, val} | rest], func, acc) do
    with {:ok, result} <- func.({key, val}) do
      acc =
        [{key, result} | acc]

      do_each_or_error(rest, func, acc)
    end
  end
end
