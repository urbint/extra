defmodule Keyword.Extra do
  @moduledoc """
  Extensions to the built-in `Keyword` module.

  """

  @type key :: Keyword.key
  @type value :: Keyword.value

  @type t :: Keyword.t

  @compile {:inline, assert_key!: 3}
  @compile {:inline, refute_key!: 3}
  @compile {:inline, default: 3}


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
  Retrieves `key` from `list`. If `list` does not have an entry under `key`, `value` is used. This
  is useful in scenarios where the following won't work:

  ```elixir
  opts =
    [optional: true, on_error: nil]

  on_error =
    opts[:on_error] || :error
  ```

  In the above example, it may be reasonable to think that `on_error` will default to `:error` when
  it the user does not specify a value for it. The issue is that the `Keyword.has_key?/2` function
  should be called instead to be sure that a value was either supplied to omitted by a user before
  resorting to the `default`. `Keyword.Extra.default/3` removes the boilerplate involved.

  This fails because `nil || true` returns `true` and `false || 12` returns `12`. This makes it
  cumbersome to use default values for fields where it is not uncommon for users to specify falsy
  values.

  ## Examples

    iex> Keyword.Extra.default([on_error: nil], :on_error, :error)
    nil

    iex> Keyword.Extra.default([name: "Bob", married: false], :married, true)
    false

  """
  @spec default(t, key, any) :: t
  def default(list, key, value) do
    case Keyword.has_key?(list, key) do
      true  ->  Keyword.get(list, key)
      false ->  value
    end
  end

end
