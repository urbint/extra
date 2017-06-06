defmodule Map.Extra do
  @moduledoc """
  Extensions to the built-in `Map` module.

  """


  @doc """
  Raises an ArgumentError error if `map` does not have the provided `key`.

  Takes an optional argument specifying the error message.

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

    case Map.has_key?(map, key) do
      true  ->
        if not nil_ok? and is_nil(Map.get(map, key)) do
          raise(ArgumentError, message)
        end

        :ok
      false ->
        raise(ArgumentError, message)
    end
  end

end
