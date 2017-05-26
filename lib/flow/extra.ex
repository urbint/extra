defmodule Flow.Extra do
  @moduledoc """
  Extensions to the `Flow` module provided by `gen_stage`.

  """

  @doc """
  Streams tuples in the form of `{:ok, any}` or `{:error, any}` and
  filtering errors and unwrapping the `:ok` tuples.

      iex> Flow.from_enumerable([{:ok, 1}, {:error, "Fail"}])
      ...> |> Flow.Extra.unwrap_oks
      ...> |> Enum.into([])
      [1]

  """
  @spec unwrap_oks(Flow.t) :: Flow.t
  def unwrap_oks(flow) do
    flow
    |> Flow.filter(fn
         {:ok, _} -> true
         {:error, _} -> false
    end)
    |> Flow.map(&elem(&1, 1))
  end
end
