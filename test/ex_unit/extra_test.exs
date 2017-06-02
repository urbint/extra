defmodule ExUnit.ExtraTest do
  use ExUnit.Case, async: true

  import ExUnit.Extra

  describe "assert_receive_either/2" do
    test "matches on pattern_a" do
      send(self(), 1)
      assert_receive_either 1, 0
    end

    test "matches on pattern_b" do
      send(self(), 0)
      assert_receive_either 1, 0
    end

    test "raises on no match" do
      assert_raise RuntimeError, ~r/No message matching either/, fn ->
        assert_receive_either 1, 0
      end
    end
  end
end
