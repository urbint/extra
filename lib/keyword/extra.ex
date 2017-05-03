defmodule Keyword.Extra do
  @moduledoc """
  Extensions to the built-in `Keyword` module.

  """

  @type key :: Keyword.key
  @type value :: Keyword.value

  @type t :: Keyword.t


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

  Takes an optional argument specifying the error message.

  """
  @spec assert_key!(t, key, String.t) :: :ok | no_return
  def assert_key!(list, key, message \\ "Key is not allowed to be in list") do
    unless Keyword.has_key?(list, key) do
      raise ArgumentError, message
    else
      :ok
    end
  end


  @doc """
  Returns the `default` value if `input` is `nil`.

  ## Example

    iex> opts = [name: "Glenn"]
    ...> Keyword.Extra.default(opts, :name, "Unspecified")
    "Glenn"

    iex> opts = [name: "Glenn"]
    ...> Keyword.Extra.default(opts, :age, "Unspecified")
    "Unspecified"

  """
  @spec default(t, key, any) :: any
  def default(list, key, default) do
    case list[key] do
      nil   -> default
      value -> value
    end
  end


end
