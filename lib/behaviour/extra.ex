defmodule Behaviour.Extra do
  @moduledoc """
  Module for useful functions and assertions for Behaviours.

  """

  @type behaviour :: module


  @doc """
  Asserts that the passed behaviour's callbacks are all implemented by the passed module.

  Throws an `ArgumentError` if any are not implemented.

  """
  @spec assert_impl!(behaviour, module) :: :ok | no_return
  def assert_impl!(behaviour, module) do
    case missing_functions(behaviour, module) do
      [] -> :ok
      missing when is_list(missing) ->
        formatted =
          missing
          |> Enum.map(fn {func, arity} -> "#{func}/#{arity}" end)

        raise ArgumentError, "module #{module} does not fully implement behaviour #{behaviour}. Missing: #{formatted}"
    end
  end


  @doc """
  Returns true if the passed behaviour's callbacks are all implemented by the passed module.

  """
  @spec implements?(behaviour, module) :: boolean
  def implements?(behaviour, module) do
    behaviour
    |> missing_functions(module)
    |> Enum.empty?()
  end


  @spec callbacks(behaviour) :: [{func :: atom, arity :: non_neg_integer}]
  defp callbacks(behaviour) do
    behaviour.behaviour_info(:callbacks)
  end


  @spec missing_functions(behaviour, module) :: [{func :: atom, arity :: non_neg_integer}]
  defp missing_functions(behaviour, module) do
    callbacks(behaviour)
    |> Enum.reject(fn {func, arity} -> function_exported?(module, func, arity) end)
  end

end
