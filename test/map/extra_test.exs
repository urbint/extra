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

    test "does not raise when the provided value is nil" do
      assert Map.Extra.assert_key!(%{first_name: nil}, :first_name) == :ok
    end

    test "raises when the provided value is nil, but :allow_nil_value is false" do
      assert_raise ArgumentError, fn ->
        Map.Extra.assert_key!(%{first_name: nil}, :first_name, allow_nil_value: false)
      end
    end
  end

  describe "take_non_nil/2" do
    test "refuses to take fields that have nil values" do
      assert Map.Extra.take_non_nil(%{address: nil}, [:address]) ==
        %{}

      assert Map.Extra.take_non_nil(%{city: "Denver", address: nil}, [:city, :address]) ==
        %{city: "Denver"}
    end

    test "takes fields from the input that have non-nil values" do
      assert Map.Extra.take_non_nil(%{address: "14 bent creek rd"}, [:address]) ==
        %{address: "14 bent creek rd"}

      assert Map.Extra.take_non_nil(%{first_name: "Marc", last_name: "Jacobs"}, [:first_name, :last_name]) ==
        %{first_name: "Marc", last_name: "Jacobs"}
    end
  end
end
