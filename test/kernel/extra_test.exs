defmodule Kernel.ExtraTest do
  use ExUnit.Case, async: true
  use PropCheck

  import ShorterMaps
  import Kernel.Extra


  describe "boolean" do
    @falsy_vals [false, nil]

    property "returns true for truthy inputs" do
      forall x <- any() do
        implies x not in @falsy_vals do
          boolean(x) == true
        end
      end
    end

    property "returns false for falsy" do
      forall x <- oneof(@falsy_vals) do
        boolean(x) == false
      end
    end
  end

  describe "defbang" do
    defmodule TestModule do
      import Kernel.Extra
      require Integer

      def only_even(x) when Integer.is_even(x), do: {:ok, x}
      def only_even(_), do: {:error, "not even"}

      def only_odd(x) when Integer.is_odd(x), do: {:ok, x}
      def only_odd(_), do: :error

      def only_positive(x) when x >= 0, do: {:ok, x}
      def only_positive(_), do: {:error, :negative}

      defbang only_even: 1, only_odd: 1, only_positive: 1
    end

    test "returns the value when the wrapped function succeeds" do
      assert TestModule.only_even(2) == {:ok, 2}
      assert TestModule.only_even!(2) == 2

      assert TestModule.only_odd(3) == {:ok, 3}
      assert TestModule.only_odd!(3) == 3
    end

    test "throws an ArgumentError. when the wrapped function fails" do
      assert {:error, msg} = TestModule.only_even(3)
      assert_raise ArgumentError, msg, fn -> TestModule.only_even!(3) end

      assert TestModule.only_odd(2) == :error
      assert_raise ArgumentError, fn -> TestModule.only_even!(3) end
    end

    test "allows the wrapped function to return atoms for errors" do
      assert {:error, :negative} = TestModule.only_positive(-1)
      assert_raise ArgumentError, "negative", fn -> TestModule.only_positive!(-1) end
    end
  end

  describe "defunion" do
    defmodule TestModule2 do
      import Kernel.Extra

      defunion :thing, [:foo, :bar, :baz]

      def module_attr, do: @things
    end

    defmodule TestModule3 do
      import Kernel.Extra

      defunion :empty_value, ["", nil]

      def module_attr, do: @empty_values
    end

    # Can't figure out how to test typespecs here, but maybe that's OK

    test "defines a function returning a list of the given values" do
      assert TestModule2.__union_things__() == [:foo, :bar, :baz]
      assert TestModule3.__union_empty_values__() == ["", nil]
    end

    test "defines a module attribute for the list of given values" do
      assert TestModule2.module_attr() == [:foo, :bar, :baz]
      assert TestModule3.module_attr() == ["", nil]
    end
  end


  describe "compose/1" do
    setup do
      add_two = fn x ->
        x + 2
      end

      divide_by_ten = fn x ->
        x / 10
      end

      {:ok, ~M{add_two, divide_by_ten}}
    end

    test """
    returns a new function composed of the list of supplied functions
    """, ~M{add_two, divide_by_ten} do

      function =
        compose([divide_by_ten, add_two])

      assert function.(8) == 1
    end
  end
end
