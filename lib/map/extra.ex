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

end
