defmodule Map.ExtraTest do
  use ExUnit.Case, async: true


  describe "assert_key!/3" do
    test "raises when the provided map does not have the specified key" do
      assert_raise ArgumentError, fn ->
        Map.Extra.assert_key!(%{first_name: "Jim"}, :last_name)
      end
    end

    test "does not raise when the provided map does has the specified key" do
      assert Map.Extra.assert_key!(%{name: "Jim Jones"}, :name) == :ok
    end

    test "raises when the provided value is nil" do
      assert_raise ArgumentError, fn ->
        Map.Extra.assert_key!(%{first_name: nil}, :first_name)
      end
    end

    test "does not raise when the provided value is nil, but nil is ok" do
      assert Map.Extra.assert_key!(%{first_name: nil}, :first_name, nil_ok: true) == :ok
    end

  end

end
