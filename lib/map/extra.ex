defmodule Map.Extra do
  @moduledoc """
  Extensions to the built-in `Map` module.

  """

  @compile {:inline, assert_key!: 3}


  @doc """
  Raises an ArgumentError error if `map` does not have the provided `key`.

  ## Options

    * `:message`: `binary`, the message to raise with when the value is missing.
    * `:nil_ok`: `boolean`, Default: `false`. Set to true if a `nil` value
      should not raise.

  """
  @spec assert_key!(map, atom, keyword) :: :ok | no_return
  def assert_key!(map, key, opts \\ []) do
    message =
      Keyword.get(opts, :message, "#{inspect(key)} is required to be in map.")

    nil_ok? =
      Keyword.get(opts, :nil_ok, false)

    case Map.fetch(map, key) do
      {:ok, nil} ->
        if not nil_ok?, do: raise(ArgumentError, message), else: :ok

      :error ->
        raise(ArgumentError, message)

      _ -> :ok
    end
  end

end
