defmodule Integer.Extra do
  @moduledoc """
  Extensions to the built-in `Integer` module.

  """


  @doc """
  Parses and returns an integer, ignoring the _rest.

    iex> Integer.Extra.parse!("12")
    12

  """
  @spec parse!(binary, 2..36) :: integer
  def parse!(string, base \\ 10) do
    {int, _rest} =
      Integer.parse(string, base)

    int
  end
end
