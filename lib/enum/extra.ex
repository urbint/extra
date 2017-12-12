defmodule Enum.Extra do
  @moduledoc """
  Extensions to the standard library's Enum module.

  """

  alias Enum.Iterator


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
  Reduces an enumerable into counts based on the result of a function.

  Useful for determining various population distributions in a dataset.

  ## Example

      iex> txs = [%{id: "A", amt: 10_000}, %{id: "B", amt: 15_000}, %{id: "C", amt: 10_000}]
      ...> txs |> Enum.Extra.count_by(& &1.amt)
      %{10_000 => 2, 15_000 => 1}

  """
  @spec count_by([map], (map -> any)) :: %{any => non_neg_integer}
  def count_by(enum, func) when is_function(func, 1) do
    Enum.reduce(enum, %{}, fn item, acc ->
      val =
        func.(item)

      Map.update(acc, val, 1, &(&1 + 1))
    end)
  end


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
    |> Stream.Extra.map_keys(fn key ->
      case Map.fetch(keymap, key) do
        {:ok, new_key} -> new_key
        :error         -> key
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
    |> Stream.Extra.map_keys(f)
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
    |> Stream.Extra.map_values(f)
    |> Enum.into(Monoid.identity(enum))
  end


  @doc """
  Looks up the first item in an enumerable for which `predicate` returns a truthy value. If a value
  is found, returns `{:ok, value}`, otherwise returns `:not_found`.

  Essentially `Enum.find`, but with tuples in the return value for easier pattern matching.

  ## Examples

      iex> Enum.Extra.lookup(["foo", "bar", "tar"], &Regex.match?(~r/ar$/, &1))
      {:ok, "bar"}
      iex> Enum.Extra.lookup(["foo", "bar", "baz"], &Regex.match?(~r/ooo/, &1))
      :not_found

  """
  @spec lookup(Enum.t, (any -> any)) :: {:ok, any} | :not_found
  def lookup(enum, predicate) do
    case Enum.find(enum, predicate) do
      nil -> :not_found
      x   -> {:ok, x}
    end
  end


  @doc """
  Fold is akin to `Enum.reduce/3`, but treats the accumulator as the subject.

      iex> Enum.Extra.fold(1, [2, 3, 4], &(&1 + &2))
      10

  Inversion of the accumulator and the `Enumerable` makes for convenient piping.
  A contrived example:

      User.new()
      |> User.set_username("jimbo")
      |> User.set_password(password)
      |> Enum.Extra.fold(friends, &User.add_friend/2)
      |> User.save()

  Note that the ordering of the element and accumulator in the reducer
  function is the same as in `Enum.reduce/2,3`.

  """
  @spec fold(any, Enum.t, (Enum.element, any -> any)) :: any
  def fold(subject, enum, fun) when is_function(fun, 2),
    do: Enum.reduce(enum, subject, fun)


  @doc """
  Behaves like `Enum.find/*` but returns the result wrapped in an `{:ok, data}` tuple.

  This function is useful for `with` pipelines where matching on `{:ok, _}` when finding the result
  is useful.

  You can optionally specify a `default` which will *not* be wrapped in any tuple

      iex> Enum.Extra.find_or_error([2, 3, 4], &(&1 == 2))
      {:ok, 2}

      iex> Enum.Extra.find_or_error([2, 3, 4], &(&1 == 5))
      :error

      iex> Enum.Extra.find_or_error([2, 3, 4], 5, &(&1 == 5))
      5

      iex> Enum.Extra.find_or_error([2, 3, 4], {:error, :not_found}, &(&1 == 5))
      {:error, :not_found}

  """
  @spec find_or_error(Enum.t, Enum.default, (Enum.element -> any))
        :: {:ok, Enum.element}
         | :error
         | Enum.default
  def find_or_error(enum, default \\ :error, fun) when is_function(fun, 1) do
    Enum.find_value(enum, default, fn x -> if fun.(x), do: {:ok, x} end)
  end


  @doc """
  Returns the enumerable from the `list_of_enums` which contains the most items.

  If there is a tie an enum earlier in `list_of_enums` will take precedence.

  Note: This function will count items in all the enums until there is only one left that has not
  halted. Using this with two infinite enums will result in this function never returning.

      iex> Enum.Extra.longest([[1], [2, 3], [4, 5, 6]])
      [4, 5, 6]

      iex> Enum.Extra.longest([[1], [2]])
      [1]

  """
  @spec longest([Enum.t]) :: Enum.t
  def longest(list_of_enums) when is_list(list_of_enums) and length(list_of_enums) > 0 do
    {{quick_enum, quick_count}, slow_counts} =
      partition_longest_quick_counts(list_of_enums)

    {slow_iter, slow_count} =
      slow_counts
      |> :lists.reverse()
      |> Enum.map(&Iterator.new/1)
      |> do_longest(0)

    cond do
      quick_count <  slow_count ->
        slow_iter.enum

      quick_count >= slow_count ->
        # If the longest quick_count is equal or longer to the longest slow_count we need to resume
        # counting the longest slow count and see which is longer. We do this by taking the delta
        # in item counts and adding 1. If it's the target length we know that `longest_iter`
        # has *at least* that many items.
        delta =
          quick_count - slow_count

        more_count =
          slow_iter |> Stream.take(delta + 1) |> Enum.count()

        cond do
          more_count > delta  -> slow_iter.enum
          more_count < delta  -> quick_enum
          more_count == delta -> Enum.find(list_of_enums, & &1 in [quick_enum, slow_iter.enum])
        end
    end
  end

  # This function partitions the input `list_of_enums` based on whether or not they implement
  # a non-default Enum.count (I call it a quick_count); We keep the the longest "quick count"
  # and return it, along with the other enums that we need to count by iterating.
  @spec partition_longest_quick_counts([Enum.t]) :: {{Enum.t, non_neg_integer}, [Enum.t]}
  defp partition_longest_quick_counts(list_of_enums) do
    list_of_enums
    |> Enum.reduce({{nil, -1}, []},
      fn enum, {{_longest_enum, longest_count} = longest, slow_counts} ->
        case Enumerable.count(enum) do
          {:ok, count} when count >  longest_count -> {{enum, count}, slow_counts}
          {:ok, count} when count <= longest_count -> {longest, slow_counts}
          {:error, _}                              -> {longest, [enum | slow_counts]}
        end
    end)
  end

  # Returns the longest Iterator passed in and the count of items we consumed from it.
  @spec do_longest([Iterator.t], non_neg_integer) :: {Iterator.t, non_neg_integer}
  defp do_longest(iterators, count) do
    for {:ok, _, iter} <- Enum.map(iterators, &Iterator.next/1) do
      iter
    end
    |> case do
      # If all of the iterators are finished, return the enum from the first iterator in this batch
      []        -> {hd(iterators), count}
      # If there is only one left, that must be our winner
      [one]     -> {one, count}
      # Otherwise, keep surviving ones and repeat
      remaining -> do_longest(remaining, count + 1)
    end
  end


  @doc """
  Returns the enumerable from the `list_of_enums` which contains the fewest items.

  If there is a tie an enum earlier in `list_of_enums` will take precedence.

  Note: This function will count items in all the enums until one of them halts. Using only
  infinite enums will result in this function never returning.

      iex> Enum.Extra.shortest([[1], [2, 3], [4, 5, 6]])
      [1]

      iex> Enum.Extra.shortest([[1], [2]])
      [1]

  """
  @spec shortest([Enum.t]) :: Enum.t
  def shortest(list_of_enums) when is_list(list_of_enums) and length(list_of_enums) > 0 do
    {{quick_enum, quick_count}, slow_counts} =
      list_of_enums
      |> Enum.reduce({{nil, nil}, []},
          fn enum, {{_longest_enum, shortest_count} = shortest, slow_counts} ->
            case Enumerable.count(enum) do
              {:ok, count} when count <  shortest_count -> {{enum, count}, slow_counts}
              {:ok, count} when count >= shortest_count -> {shortest, slow_counts}
              {:error, _}                              ->  {shortest, [enum | slow_counts]}
            end
      end)

    slow_counts
    |> :lists.reverse()
    |> Enum.map(&Iterator.new/1)
    |> do_shortest(0, quick_count)
    |> case do
      # If we exceeded the count and none of them terminated by that, use the shorted_quick_enum
      nil -> quick_enum
      # If we have a tie, use the first one in the input list
      {iter, ^quick_count} -> Enum.find(list_of_enums, &(&1 in [quick_enum, iter.enum]))
      # Otherwise, use the one we found
      {iter, _} -> iter.enum
    end
  end

  # Returns the shortest iterator in `iterators` as well as the `count` of items
  # we consumed to end it. Will consume at most `max` items at which point it will
  # stop checking.
  @spec do_shortest([Iterator.t], non_neg_integer, non_neg_integer)
        :: {Iterator.t, non_neg_integer}
         | nil
  defp do_shortest(_iterators, count, max) when count > max, do: nil
  defp do_shortest(iterators, count, max) do
    iterate_all_or_return_finished(iterators, [])
    |> case do
      # If one of the iterators terminated, we short circuit out
      %Iterator{} = iter -> {iter, count}
      # Otherwise, reverse the converted enums, increment the count and try again!
      iters              -> do_shortest(iters, count + 1, max)
    end
  end

  # Consumes the next item from all the `iterators` or returns the first one that finished.
  @spec iterate_all_or_return_finished([Iterator.t], [Iterator.t]) :: Iterator.t | [Iterator.t]
  defp iterate_all_or_return_finished([], converted),
    do: :lists.reverse(converted)
  defp iterate_all_or_return_finished([iter | rest], converted) do
    case Iterator.next(iter) do
      {:error, :done}     -> iter
      {:error, :halted}   -> iter
      {:ok, _val, next}   -> iterate_all_or_return_finished(rest, [next | converted])
    end
  end
end
