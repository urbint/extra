defmodule Behaviour.Extra do
  @moduledoc """
  Module for useful functions and assertions for Behaviours.

  """

  @type behaviour :: module


  @doc """
  Asserts that the passed behaviour's callbacks are all implemented
  by the passed module.

  Throws an `ArgumentError` if any are not implemented.

  """
  @spec assert_impl!(behaviour, module) :: :ok | no_return
  def assert_impl!(behaviour, module) do
    fully_implemented? =
      callbacks(behaviour)
      |> Enum.all?(fn {func, arity} ->
        function_exported?(module, func, arity)
      end)

    if fully_implemented? do
      :ok
    else
      raise ArgumentError, "module #{module} does not fully implement behaviour #{behaviour}."
    end
  end

  @spec callbacks(behaviour) :: [{func :: atom, arity :: non_neg_integer}]
  defp callbacks(behaviour) do
    behaviour.behaviour_info(:callbacks)
  end

end
