defmodule Struct.Extra do
  @moduledoc """
  Extensions to the built-in `Struct` module.

  """


  @doc """
  Drops the given `keys` from the `struct` while honoring the struct's original fields.

  """
  @spec drop(struct, Enum.t) :: struct
  def drop(%{__struct__: s} = record, fields) do
    Map.merge(struct(s), Map.drop(record, fields))
  end
end
