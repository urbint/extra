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


  @doc """
  Merges two of the same structs together.

  Using `Map.merge/2` is not feasible because structs typically have default values of `nil`. This
  function will not allow values of `nil` to overwrite non-nil values on merge.

  """
  @spec merge(struct, struct) :: struct
  def merge(%{__struct__: same_struct} = a, %{__struct__: same_struct} = b)
  when map_size(a) == map_size(b) do
    defaults =
      struct(same_struct)

    result =
      a
      |> Map.from_struct
      |> Enum.reduce(%{}, fn {k, a_val}, result ->
        {default, b_val} =
          {Map.get(defaults, k), Map.get(b, k)}

        case {a_val, b_val} do
          {^default, _b_val} ->
            Map.put(result, k, b_val)

          {_a_val, ^default} ->
            Map.put(result, k, a_val)

          _ ->
            Map.put(result, k, b_val)
        end
      end)

    struct(same_struct, result)
  end


  @doc """
  Convenience function for extracting the top-level keys within a struct.

  This excludes the `__struct__` key.

  """
  @spec keys(struct) :: [key :: any]
  def keys(%{__struct__: _struct} = x) do
    x |> Map.from_struct |> Map.keys
  end

end
