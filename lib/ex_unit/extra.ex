defmodule ExUnit.Extra do
  @moduledoc """
  Extensions to ExUnit for testing purposes.

  """

  @assert_receive_timeout Application.get_env(:ex_unit, :assert_receive_timeout, 100)

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


  @doc """
  Compares two MapSets and asserts that they are equal.

  Both arguments are passed through MapSet.new/1 before being compared.

    iex> import ExUnit.Extra
    ...> assert_set_equality [:a, :b], [:b, :a]
    true

  """
  defmacro assert_set_equality(set_a, set_b) do
    quote do
      assert MapSet.new(unquote(set_a)) == MapSet.new(unquote(set_b))
    end
  end


  @doc """
  Compares two MapSets and asserts that they are NOT equal.

  Both arguments are passed through MapSet.new/1 before being compared.

    iex> import ExUnit.Extra
    ...> refute_set_equality [:a, :b], [:a]
    false

  """
  defmacro refute_set_equality(set_a, set_b) do
    quote do
      refute MapSet.new(unquote(set_a)) == MapSet.new(unquote(set_b))
    end
  end

end
