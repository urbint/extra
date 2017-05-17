defmodule Enum.Extra do
  @moduledoc """
  Extensions to the standard library's Enum module.

  """


  @doc """
  Runs the `fn` for each element in the `enum`, or short circuits if
  `fn` returns an error for any given item, returning the error.

  """
  @spec each_or_error(Enum.t, (term -> {:error, reason} | any)) ::
    :ok | {:error, reason} when reason: any
  def each_or_error(enum, func) do
    Enum.into(enum, [])
    |> do_each_or_error(func)
  end

  defp do_each_or_error([], _), do: :ok
  defp do_each_or_error([item | rest], func) do
    case func.(item) do
      {:error, _} = err -> err
      _ -> do_each_or_error(rest, func)
    end
  end


  @doc """
  Runs the `func` over every value in the `Enum.t`, returning (`{:ok, Enum.t}`) if all the funcs
  return {:ok, term}.

  Short circuits if `func` does not return {:ok, term}.

  If a map or keyword list is passed, the `func` results will be set as the value on the original
  keys, such that:

      iex> Enum.Extra.map_or_error(%{a: 1, b: 2}, fn {_, val} -> {:ok, val * 2} end)
      {:ok, %{a: 2, b: 4}}

      iex> Enum.Extra.map_or_error([a: 1, b: 2], fn {_, val} -> {:ok, val * 2} end)
      {:ok, [a: 2, b: 4]}

      iex> Enum.Extra.map_or_error([1, 2], fn val -> {:ok, val * 2} end)
      {:ok, [2, 4]}

  ## Options

    * `:into`: if passed, the passed Enum.t will be collected into `:into`.
      By default, this function will attempt to push the Enum.t into the same
      structure that was passed in (a map or list).

  """
  @spec map_or_error(Enum.t, (term -> {:ok, term} | {:error, reason}), [{:into, Collectible.t}]) ::
    {:ok, Enum.t} | {:error, reason} when reason: any
  def map_or_error(enum, func, opts \\ []) do
    collectible =
      Keyword.get_lazy(opts, :into, fn -> collectible_for(enum) end)

    Enum.into(enum, [])
    |> do_map_or_error(func)
    |> case do
      result when is_list(result) ->
        collected =
           Enum.into(result, collectible)

        {:ok, collected}

      {:error, _} = err ->
        err
    end
  end


  @doc """
  Returns a `Map.t` where the elements in `list` are indexed by the value returned by calling
  `index_fn` on each element. The last writer wins in this implementation.

  """
  def index_by(list, index_fn),
    do: Enum.reduce(list, %{}, &Map.put(&2, index_fn.(&1), &1))


  defp do_map_or_error(keyword, func, acc \\ [])
  defp do_map_or_error([], _func, acc), do: acc |> Enum.reverse()
  defp do_map_or_error([next | rest], func, acc) do
    with {:ok, result} <- func.(next) do
      acc =
        case next do
          {key, _val} ->
            [{key, result} | acc]

          _ ->
            [result | acc]
        end

      do_map_or_error(rest, func, acc)
    end
  end

  defp collectible_for(enum) when is_list(enum), do: []
  defp collectible_for(enum) when is_map(enum), do: %{}

end
