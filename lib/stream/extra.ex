defmodule Stream.Extra do
  @moduledoc """
  Extensions to the built-in `Stream` module.

  """


  @doc """
  Streams tuples in the form of `{:ok, any}` or `{:error, any}`;
  filters errors and unwrapps `:ok` tuples.

    iex> Stream.Extra.unwrap_oks([{:ok, 1}, {:error, "Test"}]) |> Enum.into([])
    [1]

  """
  @spec unwrap_oks(Enumerable.t) :: Enumerable.t
  def unwrap_oks(stream) do
    stream
    |> Stream.filter(fn
      {:ok, _} -> true
      {:error, _} -> false
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

end
