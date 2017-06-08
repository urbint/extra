defmodule Keyword.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Keyword.Extra

  describe "assert_key!/3" do
    test "raises when the provided list does not have the specified key" do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_key!([first_name: "Jim"], :last_name)
      end
    end

    test "does not raise when the provided list does has the specified key" do
      assert Keyword.Extra.assert_key!([name: "Jim Jones"], :name) == :ok
    end

    test "does not raise when the provided value is nil" do
      assert Keyword.Extra.assert_key!([first_name: nil], :first_name) == :ok
    end

    test "raises when the provided value is nil, and :allow_nil_value is false" do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_key!([first_name: nil], :first_name, allow_nil_value: false)
      end
    end
  end
end
