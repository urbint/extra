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

  ## Examples

      iex> Enum.Extra.map_or_error(%{a: 1, b: 2}, fn {key, val} -> {:ok, {key, val * 2}} end)
      {:ok, %{a: 2, b: 4}}

      iex> Enum.Extra.map_or_error([a: 1, b: 2], fn {key, val} -> {:ok, {key, val * 2}} end)
      {:ok, [a: 2, b: 4]}

      iex> Enum.Extra.map_or_error([1, 2], fn val -> {:ok, val * 2} end)
      {:ok, [2, 4]}

  ## Options

    * `:into`: if passed, the passed Enum.t will be collected into `:into`.
      By default, this function will attempt to push the Enum.t into the same
      structure that was passed in (a `map` or `list`).

  """
  @spec map_or_error(Enum.t, (term -> {:ok, term} | {:error, reason}), [{:into, Collectable.t}]) ::
    {:ok, Enum.t} | {:error, reason} when reason: any
  def map_or_error(enum, func, opts \\ []) do
    collectible =
      Keyword.get_lazy(opts, :into, fn -> collectible_for(enum) end)

    Enum.to_list(enum)
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

  defp do_map_or_error(keyword, func, acc \\ [])
  defp do_map_or_error([], _func, acc), do: acc |> Enum.reverse()
  defp do_map_or_error([next | rest], func, acc) do
    with {:ok, result} <- func.(next) do
      do_map_or_error(rest, func, [result | acc])
    end
  end

  defp collectible_for(enum) when is_list(enum), do: []
  defp collectible_for(enum) when is_map(enum), do: %{}


  @doc """
  Behaves like `Enum.reduce/3` but will short-circuit if
  `fun` returns an error tuple.

  ## Examples

      iex> Enum.Extra.reduce_or_error(%{a: 1, b: 2}, 0, fn {_key, val}, count -> {:ok, val + count} end)
      {:ok, 3}

      iex> Enum.Extra.reduce_or_error([1, 2], 0, fn _val, _acc -> {:error, :fail} end)
      {:error, :fail}

  """
  @spec reduce_or_error(Enum.t, any, (Enum.element, any -> {:ok, any} | {:error, any}))
        :: {:ok, any}
         | {:error, any}
  def reduce_or_error(enum, acc, fun) do
    do_reduce_or_error(Enum.to_list(enum), acc, fun)
  end

  defp do_reduce_or_error([], acc, _), do: {:ok, acc}
  defp do_reduce_or_error([item | rest], acc, fun) do
    case fun.(item, acc) do
      {:ok, acc}        -> do_reduce_or_error(rest, acc, fun)
      {:error, _} = err -> err
    end
  end


  @doc """
  Returns a `Map.t` where the elements in `list` are indexed by the value returned by calling
  `index_fn` on each element. The last writer wins in this implementation.

  ## Examples

      iex> txs = [%{id: "A", amt: 10_000}, %{id: "B", amt: 15_000}]
      ...> txs |> Enum.Extra.index_by(& &1.id)
      %{"A" => %{id: "A", amt: 10_000}, "B" => %{id: "B", amt: 15_000}}

  """
  @spec index_by([map], (map -> any)) :: %{any => map}
  def index_by(list, index_fn),
    do: Enum.reduce(list, %{}, &Map.put(&2, index_fn.(&1), &1))


  @doc """
  Applies `mapping_fun` if `predicate` is not `false` or `nil`, otherwise returns `enum`.

  ## Examples

      iex> Enum.Extra.map_if([1, 2, 3], true, &(&1 + 1))
      [2, 3, 4]

      iex> Enum.Extra.map_if([1, 2, 3], false, &(&1 + 1))
      [1, 2, 3]

  """
  @spec map_if(Enum.t, boolean | nil, (any -> any)) :: Enum.t
  def map_if(enum, predicate, mapping_fun) when is_nil(predicate) or predicate == false and is_function(mapping_fun, 1),
    do: enum

  def map_if(enum, _predicate = true, mapping_fun) when is_function(mapping_fun, 1),
    do: Enum.map(enum, mapping_fun)


  @doc """
  Returns whether `enum` is unique.

  Note that this implementation will stop enumerating as soon as it finds a non-unique entry (returning `false`)
  making it more efficient than simply comparing `Enum.uniq(enum)` to the original `enum`.

  ## Examples

      iex> Enum.Extra.unique?([1, 2, 3])
      true

      iex> Enum.Extra.unique?([1, 1, 2])
      false

  """
  @spec unique?(Enum.t) :: boolean
  def unique?(enum) do
    unique_reducer = fn (item, seen) ->
      case MapSet.member?(seen, item) do
        true  -> {:halt, false}
        false -> {:cont, MapSet.put(seen, item)}
      end
    end

    case Enumerable.reduce(enum, {:cont, MapSet.new()}, unique_reducer) do
      {:done,   _} -> true
      {:halted, _} -> false
    end
  end

  @doc """
  Returns the given enum with the keys in `keymap` renamed to their corresponding values in
  `keymap`.
  Keys in `keymap` that don't exist in the passed enum will be ignored

  ## Examples

    iex> Enum.Extra.rename_keys([foo: "bar", baz: "qux"], %{foo: :new_foo, a: :b})
    [new_foo: "bar", baz: "qux"]

    iex> Enum.Extra.rename_keys(%{foo: "bar", baz: "qux"}, %{foo: :new_foo, a: :b})
    %{new_foo: "bar", baz: "qux"}

    iex> Enum.Extra.rename_keys([foo: "bar"], %{a: :b})
    [foo: "bar"]

  """
  @spec rename_keys(Enum.t, keymap :: map) :: keyword
  def rename_keys(enum, keymap) do
    enum
    |> Enum.map(fn {key, val} = element ->
      case Map.fetch(keymap, key) do
        {:ok, new_key} -> {new_key, val}
        :error         -> element
      end
    end)
    |> Enum.into(Monoid.identity(enum))
  end


  @doc """
  Maps the given function over the keys of the given keyed enum (a keyword or a map)

  ## Examples

      iex> %{foo: "bar", baz: "qux"} |> Enum.Extra.map_keys(&Atom.to_string/1)
      %{"foo" => "bar", "baz" => "qux"}

      iex> [foo: "bar", baz: "qux"] |> Enum.Extra.map_keys(&Atom.to_string/1)
      [{"foo", "bar"}, {"baz", "qux"}]

  """
  @spec map_keys(Enum.t, (any -> any)) :: Enum.t
  def map_keys(enum, f) do
    enum
    |> Stream.map(fn {key, val} -> {f.(key), val} end)
    |> Enum.into(Monoid.identity(enum))
  end


  @doc """
  Maps the given function over the values of the given keyed enum (a keyword or a map)

  ## Examples

      iex> %{foo: "bar", baz: "qux"} |> Enum.Extra.map_values(&String.upcase/1)
      %{foo: "BAR", baz: "QUX"}

      iex> [foo: "bar", baz: "qux"] |> Enum.Extra.map_values(&String.upcase/1)
      [foo: "BAR", baz: "QUX"]

  """
  @spec map_values(Enum.t, (any -> any)) :: Enum.t
  def map_values(enum, f) do
    enum
    |> Stream.map(fn {key, val} -> {key, f.(val)} end)
    |> Enum.into(Monoid.identity(enum))
  end
end
