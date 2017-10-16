defmodule Protocol.Extra do
  @moduledoc """
  Extensions to the standard library's Protocol module.

  """

  @doc """
  Returns the protocol module implementing the given protocol for the given *module*, or `nil` if
  the given module does not define a struct implementing the given protocol.

  Note the difference betweeen this and `MyProto.impl_for/1`, which takes an *instance* of the
  struct, whereas this takes the struct module itself.

  ## Examples

      iex> Protocol.Extra.module_impl_for(Enumerable, Stream)
      Elixir.Enumerable.Stream

      iex> Protocol.Extra.module_impl_for(String.Chars, Stream)
      nil

  """
  @spec module_impl_for(module, module) :: module | nil
  def module_impl_for(protocol, struct_module)
  when is_atom(protocol) and is_atom(struct_module) do
    impl_mod =
      Module.concat([Elixir, protocol, struct_module])

    if :erlang.module_loaded(impl_mod), do: impl_mod
  end
end
