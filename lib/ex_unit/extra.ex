defmodule ExUnit.Extra do
  @moduledoc """
  Extensions to ExUnit for testing purposes.

  """

  @assert_receive_timeout Config.get(:ex_unit, :assert_receive_timeout, 100)

  @doc """
  Allows for a receive of either pattern to pass, otherwise raises.

  """
  defmacro assert_receive_either(pattern_a, pattern_b, timeout \\ @assert_receive_timeout) do
    quote do
      timeout = unquote(timeout)
      receive do
        unquote(pattern_a) ->
          :ok
        unquote(pattern_b) ->
          :ok
      after
        timeout ->
          raise "No message matching either #{inspect unquote(pattern_a)} or #{inspect unquote(pattern_b)} after #{timeout}ms"
      end
    end
  end

end
