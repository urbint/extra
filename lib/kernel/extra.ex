defmodule Kernel.Extra do
  @moduledoc """
  Extensions to the standard library's Kernel module.

  """

  @doc """
  Coerces values into booleans.

  ## Examples

    iex> import Kernel.Extra
    ...> 12 |> boolean()
    true

    iex> import Kernel.Extra
    ...> nil |> boolean()
    false

  """
  @spec boolean(any) :: boolean
  def boolean(x),
    do: if x, do: true, else: false

end
