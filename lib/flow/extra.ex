defmodule Flow.Extra do
  @moduledoc """
  Extensions to the `Flow` module provided by `gen_stage`.

  """

  require Logger


  @doc """
  Streams tuples in the form of `{:ok, any}` or `{:error, any}` and
  filtering errors and unwrapping the `:ok` tuples.

      iex> Flow.from_enumerable([{:ok, 1}, {:error, "Fail"}])
      ...> |> Flow.Extra.unwrap_oks
      ...> |> Enum.into([])
      [1]

  """
  @spec unwrap_oks(Flow.t, keyword) :: Flow.t
  def unwrap_oks(flow, opts \\ []) do
    log_errors? =
      Keyword.get(opts, :log_errors, false)

    flow
    |> Flow.filter(fn
      {:ok, _} ->
        true

      {:error, _} = tuple ->
        if log_errors? do
          Logger.error("Encountered :error tuple. #{inspect(tuple)}")
        end

        false
    end)
    |> Flow.map(&elem(&1, 1))
  end
end
