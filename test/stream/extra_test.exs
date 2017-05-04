defmodule Stream.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true

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
end
