defmodule Keyword.Extra do
  @moduledoc """
  Extensions to the built-in `Keyword` module.

  """

  @type key :: Keyword.key
  @type value :: Keyword.value

  @type t :: Keyword.t

  @compile {:inline, assert_key!: 3}
  @compile {:inline, refute_key!: 3}


  @doc """
  Takes all entries corresponding to the given keys and returns them in a new
  keyword list in the order that `keys` arrived.

  ## Examples

    iex> Keyword.Extra.take_ordered([c: 3, b: 2, a: 1], [:a, :b])
    [a: 1, b: 2]

    iex> Keyword.Extra.take_ordered([x: 1, y: 2], [:x, :y, :z])
    [x: 1, y: 2]

    iex> location = %{state: "NY", city: "Manhattan", zip_code: "10009"}
    ...> Keyword.Extra.take_ordered(location, [:city, :state, :zip_code])
    [city: "Manhattan", state: "NY", zip_code: "10009"]

  """
  @spec take_ordered(t, [key]) :: t
  @spec take_ordered(map, [key]) :: t
  def take_ordered([{key, _value} | _rest] = kw_list, keys)
    when is_atom(key),
    do: do_take_ordered(kw_list, keys)

  def take_ordered(%{} = map, keys) do
    map
    |> Keyword.new
    |> do_take_ordered(keys)
  end

  @spec do_take_ordered(t, [key]) :: t
  defp do_take_ordered(kw_list, keys) do
    keys
    |> Stream.filter(&Keyword.has_key?(kw_list, &1))
    |> Enum.map(&get_pair(kw_list, &1))
  end

  @spec get_pair(t, key) :: {key, value} | nil
  defp get_pair(kw_list, key) do
    with {:ok, value} <- Keyword.fetch(kw_list, key) do
      {key, value}
    else
      :error -> nil
    end
  end


  @doc """
  Raises an ArgumentError error if `list` contains the provided `key`.

  Takes an optional argument specifying the error message.

  """
  @spec refute_key!(t, key, String.t) :: :ok | no_return
  def refute_key!(list, key, message \\ "Key is not allowed to be in list") do
    if Keyword.has_key?(list, key) do
      raise ArgumentError, message
    else
      :ok
    end
  end


  @doc """
  Raises an ArgumentError error if `list` does not have the provided `key`.

  ## Options

    * `:message`: `binary`, the message to raise with when the value is missing.
    * `:allow_nil_value`: `boolean`, Default: `true`. Set to true if a `nil` value
      should not raise.

  """
  @spec assert_key!(t, key, keyword) :: :ok | no_return
  def assert_key!(list, key, opts \\ []) do
    message =
      Keyword.get(opts, :message, "#{inspect(key)} is required to be in keyword list.")

    allow_nil_value? =
      Keyword.get(opts, :allow_nil_value, true)

    case Keyword.fetch(list, key) do
      {:ok, nil} when not allow_nil_value? ->
        raise(ArgumentError, message)

      :error ->
        raise(ArgumentError, message)

      _ -> :ok
    end
  end


  @doc """
  Fetches the values for the specified `keys`.

  If any of the `keys` do not exist, a `KeyError` is raised.

  ## Examples

    iex> Keyword.Extra.fetch_keys!([color: "blue"], [:color])
    ["blue"]

  """
  @spec fetch_keys!(t, [key]) :: [value]
  def fetch_keys!(list, keys),
    do: keys |> Enum.map(&Keyword.fetch!(list, &1))


  @doc """
  Gets the values for the specified `keys`.

  Pass default values for keys using the following format: `{key, default}`. If any of the `keys` do
  not exist, return `nil` or use the default value if supplied.

  ## Examples

    iex> Keyword.Extra.get_keys([ssn: "1234", age: 41], [:age, :ssn])
    [41, "1234"]

    iex> Keyword.Extra.get_keys([first_name: "Bob"], [first_name: :missing, last_name: :missing])
    ["Bob", :missing]

  """
  @spec get_keys(t, [key | {key, default :: any}]) :: [value]
  def get_keys(list, keys) do
    keys |> Enum.map(fn
      {key, default} -> Keyword.get(list, key, default)
      key -> Keyword.get(list, key)
    end)
  end

end
