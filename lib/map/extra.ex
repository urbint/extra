defmodule Map.Extra do
  @moduledoc """
  Extensions to the built-in `Map` module.

  """

  @compile {:inline, assert_key!: 3}


  @doc """
  Raises an ArgumentError error if `map` does not have the provided `key`.

  ## Options

    * `:message`: `binary`, the message to raise with when the value is missing.
    * `:allow_nil_value`: `boolean`, Default: `true`. Set to true if a `nil` value
      should not raise.

  """
  @spec assert_key!(map, atom, keyword) :: :ok | no_return
  def assert_key!(map, key, opts \\ []) do
    message =
      Keyword.get(opts, :message, "#{inspect(key)} is required to be in map.")

    allow_nil_value? =
      Keyword.get(opts, :allow_nil_value, true)

    case Map.fetch(map, key) do
      {:ok, nil} when not allow_nil_value? ->
        raise(ArgumentError, message)

      :error ->
        raise(ArgumentError, message)

      _ -> :ok
    end
  end


  @doc """
  Takes the fields specified by `keys` from `map` if their values are present and non `nil`.

  ## Examples

    iex> Map.Extra.take_non_nil(%{name: nil}, [:name])
    %{}

    iex> Map.Extra.take_non_nil(%{name: "Jerome"}, [:name])
    %{name: "Jerome"}

  """
  @spec take_non_nil(map, list) :: map
  def take_non_nil(map, keys) do
    :lists.foldl(fn key, acc ->
      case Map.get(map, key) do
        nil -> acc
        val -> Map.put(acc, key, val)
      end
    end, %{}, keys)
  end


  @doc """
  Raises an ArgumentError if `map` does not have all of the provided `keys`.

  ## Options

    * `:message`: `binary`, the message to raise with when the value is missing.
    * `:allow_nil_value`: `boolean`, Default: `true`. Set to true if a `nil` value
      should not raise.

  """
  @spec assert_keys!(map, [key :: any], keyword) :: :ok | no_return
  def assert_keys!(map, keys, opts \\ []) do
    for key <- keys, do: assert_key!(map, key, opts)
    :ok
  end


  @doc """
  Returns `true` if the `map` has all of the `keys`.

  """
  @spec has_keys?(map, Enum.t) :: boolean
  def has_keys?(map, keys) do
    keys |> Enum.all?(&Map.has_key?(map, &1))
  end


  @doc """
  Fetches all of the values for the specified `keys` from `map`.

  Raises a `KeyError` if any of the specified keys does not exist.

  ## Examples

    iex> Map.Extra.fetch_all!(%{red: 255, green: 200, blue: 150}, [:red, :blue])
    [255, 150]

  """
  @spec fetch_all!(map, [key :: any]) :: [any] | no_return
  def fetch_all!(map, keys) do
    keys |> Enum.map(&Map.fetch!(map, &1))
  end


  @doc """
  Recursively flattens a nested map.

  Currently this only works when the keys are strings. It accepts the following options:

  ## Options

    * `:namespace` - Prepends the snakecased path to each key if set to `true`.
      Defaults to `true`.

    * `:delimiter` - The string to use as the delimiter when namespacing.
      Defaults to `"_"`.

  ## Examples

    iex> Map.Extra.flatten(%{"person" => %{"first_name" => "Joe", "last_name" => "Montana"}})
    %{"person_first_name" => "Joe", "person_last_name" => "Montana"}

    iex> Map.Extra.flatten(%{"person" => %{"first_name" => "Joe", "last_name" => "Montana"}}, namespace: false)
    %{"first_name" => "Joe", "last_name" => "Montana"}

  """
  @spec flatten(map, keyword) :: map
  def flatten(map, opts \\ []) do
    namespaced? =
      Keyword.get(opts, :namespace, true)

    delimiter =
      Keyword.get(opts, :delimiter, "_")

    Enum.reduce(map, %{}, fn
      {key, %{__struct__: _} = value}, acc ->
        Map.put(acc, key, value)

      {key, value}, acc when is_map(value) ->
        flattened =
          if namespaced? do
            value
            |> flatten(namespaced: namespaced?, delimiter: delimiter)
            |> Stream.map(fn {child_key, value} -> {key <> delimiter <> child_key, value} end)
            |> Enum.into(%{})
          else
            # there is no need to forward namespaced? or delimiter to flatten
            # since namespaced is false
            flatten(value)
          end

        Map.merge(acc, flattened)

      {key, value}, acc ->
        Map.put(acc, key, value)
    end)
  end

end
