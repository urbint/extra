defmodule Tuple.Extra do
  @moduledoc """
  Extensions to the `Tuple` module.

  """



  ##################################################################################
  # Public API
  ##################################################################################

  @doc """
  Unwraps an `:ok` tuple or raises an error.

  ## Examples

    iex> Tuple.Extra.unwrap_ok!({:ok, 5})
    5

  """
  @spec unwrap_ok!({:ok, val} | {:error, any}) :: val | no_return
        when val: var
  def unwrap_ok!(tuple) do
    case tuple do
      {:ok, val}  -> val
      {:error, _} -> raise("Error unwrapping tuple: #{inspect tuple}")
    end
  end


  @doc """
  Unwraps an `:ok` tuple or returns a default value.

  ## Examples

    iex> Tuple.Extra.unwrap_ok_with_default({:ok, 5}, 0)
    5

    iex> Tuple.Extra.unwrap_ok_with_default({:error, :fail}, 0)
    0

  """
  @spec unwrap_ok_with_default({:ok, val} | {:error, any}, default) :: val | default
        when val: var, default: var
  def unwrap_ok_with_default({:ok, val}, _default),
    do: val
  def unwrap_ok_with_default({:error, _}, default),
    do: default


  @doc """
  Wraps `data` with a `tag` atom.

  Useful for piping data into `:ok` and `:error` tuples.

  ## Examples

    iex> Tuple.Extra.wrap_with(5, :ok)
    {:ok, 5}

  """
  @spec wrap_with(term, atom) :: {atom, term}
  def wrap_with(data, atom) when is_atom(atom) do
    {atom, data}
  end
end
