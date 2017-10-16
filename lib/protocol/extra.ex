defmodule Protocol.Extra do
  @moduledoc """
  Extensions to the standard library's Protocol module.

  """

  @doc """
  Returns true if the given *module* defines a struct which implements the given protocol.

  ## Examples

      iex> Protocol.Extra.module_implements?(Enumerable, Stream)
      true

      iex> Protocol.Extra.module_implements?(String.Chars, Stream)
      false

  """
  @spec module_implements?(Protocol.t, module) :: boolean
  def module_implements?(protocol, struct_module)
  when is_atom(protocol) and is_atom(struct_module) do
    impl_mod =
      Module.concat([Elixir, protocol, struct_module])

    :erlang.module_loaded(impl_mod)
  end
end
