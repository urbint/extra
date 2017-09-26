defmodule ExUnit.ExtraTest do
  use ExUnit.Case, async: true

  import ExUnit.Extra

  doctest ExUnit.Extra

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

  describe "assert_set_equality/2" do
    test "correct for mapsets" do
      assert_set_equality MapSet.new([:a, :b]), MapSet.new([:b, :a])
      refute_set_equality MapSet.new([:a]), MapSet.new([:b, :a])
    end

    test "correct for lists" do
      assert_set_equality [:a, :b], [:b, :a]
      refute_set_equality [:a], [:b, :a]
    end

    test "correct for mixed" do
      assert_set_equality MapSet.new([:a, :b]), [:b, :a]
      assert_set_equality MapSet.new([:a, :b]), [:a, :b]
      refute_set_equality [:a, :b, :c], MapSet.new([:a])
    end
  end
end
