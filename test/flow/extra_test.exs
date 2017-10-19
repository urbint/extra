defmodule Flow.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Flow.Extra

  import ExUnit.CaptureLog


  describe "unwrap_oks/2" do
    test "unwraps ok tuples" do
      enum =
        [{:ok, 1}, {:error, 2}, {:ok, 3}]
        |> Flow.from_enumerable()

      assert [1, 3] ==
        enum |> Flow.Extra.unwrap_oks() |> Enum.into([])
    end

    test "logs when the log_errors option is passed" do
      enum =
        [{:ok, 1}, {:error, 2}, {:ok, 3}]
        |> Flow.from_enumerable()

      assert capture_log(fn ->
        enum |> Flow.Extra.unwrap_oks(log_errors: true) |> Stream.run
      end) =~ "Encountered :error tuple. {:error, 2}"
    end
  end
end
