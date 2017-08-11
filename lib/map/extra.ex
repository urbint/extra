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

end
