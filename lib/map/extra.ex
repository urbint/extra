defmodule Map.Extra do
  @moduledoc """
  Extensions to the built-in `Map` module.

  """


  @doc """
  Raises an ArgumentError error if `map` does not have the provided `key`.

  Takes an optional argument specifying the error message.

  """
  @spec assert_key!(map, atom, String.t | nil) :: :ok | no_return
  def assert_key!(map, key, message \\ nil) do
    message =
      case message do
        nil -> "#{inspect(key)} is required to be in map."
        msg when is_binary(msg) -> msg
      end

    case Map.has_key?(map, key) do
      true  -> :ok
      false -> raise(ArgumentError, message)
    end
  end

end
