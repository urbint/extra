defmodule Module.Extra do
  @moduledoc """
  Module providing functions and assertions for the Elixir `Module` module.

  """


  @doc """
  Asserts that the passed module exists.

  Raises an ArgumentError if it does not.

  """
  @spec assert_exists!(module) :: :ok | no_return
  def assert_exists!(module) do
    try do
      module.__info__(:module)
    rescue
      UndefinedFunctionError ->
        # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
        raise ArgumentError, "module #{module} does not exist or is not loaded."
    end


    :ok
  end
end
