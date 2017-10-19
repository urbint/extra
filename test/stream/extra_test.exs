defmodule Stream.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  doctest Stream.Extra


  describe "on_finish/2" do
    test "calls function when the stream finishes enumerating" do
      pid =
        self()

      [1, 2, 3]
      |> Stream.Extra.on_finish(fn -> send(pid, :finished) end)
      |> Stream.run()

      assert_receive :finished
    end
  end


  describe "unwrap_oks!/1" do
    test "unwraps :ok tuples" do
      enum =
        [{:ok, 1}, {:ok, 2}, {:ok, 3}]

      assert enum |> Stream.Extra.unwrap_oks! |> Enum.into([]) == [1, 2, 3]
    end

    test "raises when an error tuple is encountered" do
      enum =
        [{:ok, 1}, {:error, 2}, {:ok, 3}]

      assert_raise ArgumentError, fn ->
        enum |> Stream.Extra.unwrap_oks! |> Stream.run
      end
    end
  end


  describe "unwrap_oks/2" do
    test "logs when the log_errors option is passed" do
      enum =
        [{:ok, 1}, {:error, 2}, {:ok, 3}]

      assert capture_log(fn ->
        enum |> Stream.Extra.unwrap_oks(log_errors: true) |> Stream.run
      end) =~ "Encountered :error tuple. {:error, 2}"
    end
  end

end
