defmodule Map.ExtraTest do
  use ExUnit.Case, async: true

  import ShorterMaps


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

  describe "assert_keys!/3" do
    test "raises when the provided map does not have all of the specified keys" do
      assert_raise ArgumentError, fn ->
        Map.Extra.assert_keys!(%{first_name: "Jim"}, [:first_name, :last_name])
      end
    end

    test "does not raise when the provided map does has the specified keys" do
      assert :ok = Map.Extra.assert_keys!(%{name: "Jim Jones", age: 42}, [:name, :age])
    end
  end


  describe "has_keys!/2" do
    test "returns true if the map has all of the keys specified" do
      assert Map.Extra.has_keys?(%{fname: "Jim", lname: "Carey"}, [:fname, :lname])
    end

    test "returns false if the map has all of the keys specified" do
      refute Map.Extra.has_keys?(%{fname: "Jim", lname: "Carey"}, [:fname, :lname, :age])
    end

    test "returns true if keys are an empty list" do
      assert Map.Extra.has_keys?(%{fname: "Jim", lname: "Carey"}, [])
    end
  end


  describe "fetch_all!/2" do
    setup do
      map =
        %{fname: "John", lname: "Cleese"}

      {:ok, ~M{map}}
    end

    test "returns the values for all of the requested keys", ~M{map} do
      assert Map.Extra.fetch_all!(map, [:fname, :lname]) == ["John", "Cleese"]
    end

    test "raises a KeyError when a requested key does not exist", ~M{map} do
      assert_raise KeyError, fn ->
        Map.Extra.fetch_all!(map, [:fname, :lname, :age])
      end
    end
  end
end
