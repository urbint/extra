defmodule ExUnit.Extra do
  @moduledoc """
  Extensions to ExUnit for testing purposes.

  """

  import ExUnit.Assertions

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
  Convert two `Enumerable`s into `MapSet`s and asserts that they are equal.

    iex> import ExUnit.Extra
    ...> assert_set_equality [:a, :b], [:b, :a]
    true

  """
  def assert_set_equality(a, b) do
    assert MapSet.new(a) == MapSet.new(b)
  end


  @doc """
  Convert two `Enumerable`s into `MapSet`s and refutes that they are equal.

      iex> import ExUnit.Extra
      ...> refute_set_equality [:a, :b], [:a]
      true

  """
  @spec refute_set_equality(Enum.t, Enum.t) :: boolean | no_return
  def refute_set_equality(a, b) do
    assert MapSet.new(a) != MapSet.new(b)
  end

end
