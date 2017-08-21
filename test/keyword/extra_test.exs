defmodule Keyword.ExtraTest do
  @moduledoc false

  import ShorterMaps
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


  describe "fetch_keys!/2" do
    setup do
      opts =
        [name: "Bob", age: 65]
      {:ok, ~M{opts}}
    end

    test "gets the values for the list of keys", ~M{opts} do
      assert Keyword.Extra.fetch_keys!(opts, [:name, :age]) == ["Bob", 65]
    end

    test "returns the values in the same order in which they are requested", ~M{opts} do
      assert Keyword.Extra.fetch_keys!(opts, [:age, :name]) == [65, "Bob"]
    end

    test "fails when a requested key is not present", ~M{opts} do
      assert_raise KeyError, fn ->
        Keyword.Extra.fetch_keys!(opts, [:weight])
      end

      assert_raise KeyError, fn ->
        Keyword.Extra.fetch_keys!(opts, [:name, :age, :weight])
      end
    end
  end
end
