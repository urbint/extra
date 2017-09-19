defmodule Keyword.ExtraTest do
  @moduledoc false

  import ShorterMaps
  use ExUnit.Case, async: true
  doctest Keyword.Extra


  describe "assert_any!/3" do
    setup do
      keyword =
        [a: :present, b: :present, c: :present]

      {:ok, ~M{keyword}}
    end

    test "does not raise when the list has at least one of the keys", ~M{keyword} do
      assert :ok = Keyword.Extra.assert_any!(keyword, [:a, :z])
      assert :ok = Keyword.Extra.assert_any!(keyword, [:b, :z])
      assert :ok = Keyword.Extra.assert_any!(keyword, [:c, :z])
      assert :ok = Keyword.Extra.assert_any!(keyword, [:a, :b, :c])
    end

    test "raises when the list does not have any of the keys", ~M{keyword} do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_any!(keyword, [:d, :e, :f])
      end
    end

    test "accepts an enumerable as the collection of keys", ~M{keyword} do
      keys =
        MapSet.new([:a, :b, :c])

      assert :ok = Keyword.Extra.assert_any!(keyword, keys)
    end

    test "accepts a custom message to use when raising errors", ~M{keyword} do
      assert_raise ArgumentError, "Custom message.", fn ->
        Keyword.Extra.assert_any!(keyword, [:d, :e, :f], message: "Custom message.")
      end
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

    test "does not raise when the provided value is nil" do
      assert Keyword.Extra.assert_key!([first_name: nil], :first_name) == :ok
    end

    test "raises when the provided value is nil, and :allow_nil_value is false" do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_key!([first_name: nil], :first_name, allow_nil_value: false)
      end
    end
  end


  describe "assert_keys!/3" do
    setup do
      list =
        [fname: "Peter", lname: "Logan"]

      {:ok, ~M{list}}
    end

    test "raises an ArgumentError when the provided list does not have all of the keys", ~M{list} do
      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_keys!(list, [:fname, :lname, :oops])
      end
    end

    test "does not raise when the provided keys are present", ~M{list} do
      assert Keyword.Extra.assert_keys!(list, [:fname, :lname]) == :ok
    end

    test "raises when a value is nil and :allow_nil_value is false", ~M{list} do
      list =
        Keyword.put(list, :nil_value, nil)

      assert_raise ArgumentError, fn ->
        Keyword.Extra.assert_keys!(list, [:fname, :lname, :nil_value], allow_nil_value: false)
      end
    end
  end


  describe "fetch_all!/2" do
    setup do
      opts =
        [name: "Bob", age: 65]

      {:ok, ~M{opts}}
    end

    test "gets the values for the list of keys", ~M{opts} do
      assert Keyword.Extra.fetch_all!(opts, [:name, :age]) == ["Bob", 65]
    end

    test "returns the values in the same order in which they are requested", ~M{opts} do
      assert Keyword.Extra.fetch_all!(opts, [:age, :name]) == [65, "Bob"]
    end

    test "fails when a requested key is not present", ~M{opts} do
      assert_raise KeyError, fn ->
        Keyword.Extra.fetch_all!(opts, [:weight])
      end

      assert_raise KeyError, fn ->
        Keyword.Extra.fetch_all!(opts, [:name, :age, :weight])
      end
    end
  end


  describe "get_all/2" do
    setup do
      opts =
        [name: "Bob", age: 65]

      {:ok, ~M{opts}}
    end

    test "gets the values for the list of keys", ~M{opts} do
      assert Keyword.Extra.get_all(opts, [:name, :age]) == ["Bob", 65]
    end

    test "uses nil for non-existent keys", ~M{opts} do
      assert Keyword.Extra.get_all(opts, [:name, :age, :weight]) == ["Bob", 65, nil]
    end

    test "uses the provided defaults when they are provided", ~M{opts} do
      assert Keyword.Extra.get_all(opts, [:name, :age, weight: 99.9]) == ["Bob", 65, 99.9]
    end
  end
end
