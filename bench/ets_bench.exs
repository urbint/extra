defmodule ETSBench do
  use Benchfella

  before_each_bench _ do
    table =
      :ets.new(:bench_table, [:public])

    for x <- 1..100_000 do
      :ets.insert(table, {x, x + 1})
    end

    {:ok, table}
  end

  after_each_bench table do
    :ets.delete(table)
  end

  bench "stream_keys/1", [table: bench_context] do
    table
    |> ETS.Extra.stream_keys()
    |> Stream.run()
  end
end
