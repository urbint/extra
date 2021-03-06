defmodule Stream.Extra do
  @moduledoc """
  Extensions to the built-in `Stream` module.

  """

  alias Enum.Iterator

  require Logger


  @doc """
  Maps the given function over the keys of the given keyed `enum` (a keyword or a map)

  ## Examples

      iex> %{foo: "bar", baz: "qux"} |> Stream.Extra.map_keys(&Atom.to_string/1) |> Enum.into(%{})
      %{"foo" => "bar", "baz" => "qux"}

      iex> [foo: "bar", baz: "qux"] |> Stream.Extra.map_keys(&Atom.to_string/1) |> Enum.to_list()
      [{"foo", "bar"}, {"baz", "qux"}]

  """
  @spec map_keys(Enum.t, (any -> any)) :: Enum.t
  def map_keys(enum, f) do
    enum
    |> Stream.map(fn {key, val} -> {f.(key), val} end)
  end


  @doc """
  Maps the given function over the values of the given keyed `enum` (a keyword or a map)

  ## Examples

      iex> %{foo: "bar", baz: "qux"} |> Stream.Extra.map_values(&String.upcase/1) |> Enum.into(%{})
      %{foo: "BAR", baz: "QUX"}

      iex> [foo: "bar", baz: "qux"] |> Stream.Extra.map_values(&String.upcase/1) |> Enum.to_list()
      [foo: "BAR", baz: "QUX"]

  """
  @spec map_values(Enum.t, (any -> any)) :: Enum.t
  def map_values(enum, f) do
    enum
    |> Stream.map(fn {key, val} -> {key, f.(val)} end)
  end


  @doc """
  Streams tuples in the form of `{:ok, any}` or `{:error, any}`. Rejects `:error` tuples while unwrapping
  `:ok` tuples.

    iex> Stream.Extra.unwrap_oks([{:ok, 1}, {:error, "Test"}]) |> Enum.into([])
    [1]

  """
  @spec unwrap_oks(Enumerable.t, keyword) :: Enumerable.t
  def unwrap_oks(stream, opts \\ []) do
    log_errors? =
      Keyword.get(opts, :log_errors, false)

    stream
    |> Stream.filter(fn
      {:ok, _} ->
        true

      {:error, _} = tuple ->
        if log_errors? do
          Logger.error("Encountered :error tuple. #{inspect(tuple)}")
        end

        false
    end)
    |> Stream.map(&elem(&1, 1))
  end


  @doc """
  Unwraps a stream of `{:ok, any}` tuples. Raises an `ArgumentError` if it encounters a
  `{:error, ...}` tuple.

  """
  @spec unwrap_oks!(Enumerable.t) :: Enumerable.t
  def unwrap_oks!(stream) do
    stream
    |> Stream.filter(fn
      {:ok, _} -> true
      {:error, _} = tuple -> raise(ArgumentError, "Encountered :error tuple. #{inspect(tuple)}")
    end)
    |> Stream.map(&elem(&1, 1))
  end


  @doc """
  Filters out the `nil` and `{_, nil}` values from an `Enumerable`.

    iex> Stream.Extra.filter_nil_values([1, 2, nil]) |> Enum.to_list
    [1, 2]

    iex> Stream.Extra.filter_nil_values(%{a: "test", b: nil}) |> Enum.into(%{})
    %{a: "test"}

  """
  @spec filter_nil_values(Enumerable.t) :: Enumerable.t
  def filter_nil_values(stream) do
    stream
    |> Stream.filter(fn
      {_, nil} -> false
      nil -> false
      _ -> true
    end)
  end


  @doc """
  Executes `fun` after `enum` has finished.

  """
  @spec on_finish(Enumerable.t, (() -> any)) :: Enumerable.t
  def on_finish(enum, fun) when is_function(fun, 0) do
    Stream.transform(enum, fn -> nil end, &({[&1], &2}), fn nil ->
        fun.()
    end)
  end


  @doc """
  Merges two sorted streams into one sorted stream.

  `comparator` may optionally be passed as a function which will compare two arbitrary elements of
  the stream for order. Defaults to `<=`

  ## Examples

      iex> Stream.Extra.sorted_merge(
      ...>   [1, 3, 6, 7],
      ...>   [2, 4, 5, 8, 9, 10]
      ...> ) |> Enum.to_list()
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      iex> Stream.Extra.sorted_merge(
      ...>   [7, 6, 3, 1],
      ...>   [10, 9, 8, 5, 2],
      ...>   &Kernel.>=/2
      ...> ) |> Enum.to_list()
      [10, 9, 8, 7, 6, 5, 3, 2, 1]

  """
  @spec sorted_merge(Enumerable.t, Enumerable.t, ((any, any) -> boolean)) :: Enumerable.t
  def sorted_merge(enum_a, enum_b, comparator) when is_function(comparator, 2) do
    sorted_merge([enum_a, enum_b], comparator)
  end

  @doc """
  Merges any number of sorted streams into one sorted stream.

  `comparator` may optionally be passed as a function which will compare two arbitrary elements of
  the stream for order. Defaults to `<=`

  ## Examples

      iex> Stream.Extra.sorted_merge([
      ...>   [1, 3, 6, 7],
      ...>   [4, 8, 9],
      ...>   [2, 5, 8]
      ...> ]) |> Enum.to_list()
      [1, 2, 3, 4, 5, 6, 7, 8, 8, 9]

      iex> Stream.Extra.sorted_merge([
      ...>   [7, 6, 3, 1],
      ...>   [9, 8, 4],
      ...>   [8, 5, 2]
      ...> ], &Kernel.>=/2) |> Enum.to_list()
      [9, 8, 8, 7, 6, 5, 4, 3, 2, 1]

  """
  @spec sorted_merge([Enumerable.t], ((any, any) -> boolean)) :: Enumerable.t
  def sorted_merge(enums, comparator) when is_list(enums) and is_function(comparator, 2) do
    iterators =
      Enum.map(enums, &Iterator.new/1)

    &do_sorted_merge(iterators, &1, &2, comparator)
  end

  def sorted_merge(enum_a, enum_b), do: sorted_merge([enum_a, enum_b], &Kernel.<=/2)
  def sorted_merge(enums) when is_list(enums), do: sorted_merge(enums, &Kernel.<=/2)

  defp do_sorted_merge(iterators, {:halt, acc}, _callback, _comparator) do
    # If the stream that's consuming us tells us to halt, tell all our enums to halt and return the
    # current accumulator
    do_sorted_merge_close(iterators)
    {:halted, acc}
  end

  defp do_sorted_merge(enums, {:suspend, acc}, callback, comparator) do
    # If the stream that's consuming us tells us to suspend, save a continuation thunk and return
    # that and the current accumulator
    {:suspended, acc, &do_sorted_merge(enums, &1, callback, comparator)}
  end

  defp do_sorted_merge(enums, {:cont, acc}, callback, comparator) do
    do_sorted_merge_next_element(enums, acc, callback, comparator)
  catch
    kind, reason ->
      stacktrace = System.stacktrace
      # If something throws, make sure to close all upstream enums
      do_sorted_merge_close(enums)
      :erlang.raise(kind, reason, stacktrace)
  else
    {:next, buffer, acc}  -> do_sorted_merge(buffer, acc, callback, comparator)
    {:done, _acc} = other -> other
  end

  defp do_sorted_merge_next_element([last_iter], acc, callback, _comparator) do
    iter =
      case last_iter do
        %Iterator{} = iter      -> iter
        {_, %Iterator{} = iter} -> iter
      end

    # If we're down to only one enumerator left, just consume it until it's done
    case Iterator.next(iter) do
      {:ok, x, iter}                               -> {:next, [iter], callback.(x, acc)}
      {:error, stop} when stop in [:done, :halted] -> {:done, acc}
    end
  end

  defp do_sorted_merge_next_element(iterators, acc, callback, comparator) do
    {{next, idx_taken, next_iter_for_idx}, new_iters, finished_iters} =
      # Walk through each of the enums...
      iterators
      # Peeking the next element...
      |> Stream.map(fn
        %Iterator{} = iter      -> Iterator.next(iter)
        {x, %Iterator{} = iter} -> {:ok, x, iter}
      end)
      # And retaining:
      # - the current minimum value taken,
      # - the index of the enum that yielded that minimum value,
      # - the next thunk for the enum that yielded that minimum value,
      # - a list of yielded values
      |> Stream.with_index()
      |> Enum.reduce({{:"$init", nil, nil}, [], []}, fn
        {{:ok, x, next_iter}, idx}, {{min, _, _} = current, peeked, finished_iters} ->
          if min == :"$init" or comparator.(x, min) do
            {{x, idx, next_iter}, [{x, next_iter} | peeked], finished_iters}
          else
            {current, [{x, next_iter} | peeked], finished_iters}
          end
        {{:error, stop}, idx}, {current, peeked, finished_iters} when stop in [:done, :halted] ->
          # Put a nil at the top of the peeked list that will later be removed so that the index of
          # the taken element stays stable
          {current, [nil | peeked], [idx | finished_iters]}
      end)

    if next == :"$init" do
      {:done, acc}
    else
      iterators =
        new_iters
        |> Enum.reverse()
        # After we're done, replace the enum that gave us the smallest value with its next thunk...
        |> List.replace_at(idx_taken, next_iter_for_idx)
        # and remove all the enums that have finished.
        |> Enum.Extra.fold(finished_iters, &List.delete_at(&2, &1))

      {:next, iterators, callback.(next, acc)}
    end
  end

  defp do_sorted_merge_close(iterators) do
    Enum.each(iterators, fn
      %Iterator{} = iter      -> Iterator.halt(iter)
      {_, %Iterator{} = iter} -> Iterator.halt(iter)
    end)
  end

end
