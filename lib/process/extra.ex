defmodule Process.Extra do
  @moduledoc """
  Extensions to the standard library's `Process` module.
  
  """

  @doc """
  Exits the specified `pid_or_atom` with the provided `:reason`.
  
  This function is similar to `Process.kill/2` with the following differences:

  It accepts an atom, in which case it will attempt to resolve the module via `Process.whereis/1`,
  and if it is unable to resolve it will function as a no-op.
  
  """
  @spec exit(atom | pid, reason :: term) :: true
  def exit(atom, reason) when is_atom(atom) do
    case Process.whereis(atom) do
      nil                  -> true
      pid when is_pid(pid) -> exit(pid, reason)
    end
  end

  def exit(pid, reason) when is_pid(pid) do
    Process.exit(pid, reason)
  end
end
