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
        default =
          Map.get(defaults, k)

        case default do
          # overwrite A if it has its default value
          ^a_val ->
            Map.put(result, k, Map.get(b, k))

          _non_default ->
            # credo:disable-for-next-line Credo.Check.Refactor.Nesting
            case Map.get(b, k) do
              ^default -> Map.put(result, k, a_val)
              b_val    -> Map.put(result, k, b_val)
            end
        end
      end)

    struct(same_struct, result)
  end

end
