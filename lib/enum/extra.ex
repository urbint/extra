defmodule Enum.Extra do
  @moduledoc """
  Extensions to the standard library's Enum module.

  """


  @doc """
  Runs the `fn` for each element in the `enum`, or short circuits if
  `fn` returns an error for any given item, returning the error.

  """
  @spec each_or_error(Enum.t, (term -> {:error, reason} | any)) ::
    :ok | {:error, reason} when reason: any
  def each_or_error(enum, func) do
    Enum.into(enum, [])
    |> do_each_or_error(func)
  end

  defp do_each_or_error([], _), do: :ok
  defp do_each_or_error([item | rest], func) do
    case func.(item) do
      {:error, _} = err -> err
      _ -> do_each_or_error(rest, func)
    end
  end
end
