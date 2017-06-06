defmodule Keyword.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Keyword.Extra

  describe "default/3" do
    test "Uses falsy values when they're supplied by the user" do
      assert Keyword.Extra.default([optional: true, on_error: nil], :on_error, :error) == nil
    end

    test "Uses default values when the user does not supply a value" do
      assert Keyword.Extra.default([optional: true], :on_error, :error) == :error
    end
  end

  describe "assert_key!/3" do
    test "raises when the provided list does not have the specified key" do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_key!([first_name: "Jim"], :last_name)
      end
    end

    test "does not raise when the provided list does has the specified key" do
      assert Keyword.Extra.assert_key!([name: "Jim Jones"], :name) == :ok
    end

    test "raises when the provided value is nil" do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_key!([first_name: nil], :first_name)
      end
    end

    test "does not raise when the provided value is nil, but nil is ok" do
      assert Keyword.Extra.assert_key!([first_name: nil], :first_name, nil_ok: true) == :ok
    end
  end
end
