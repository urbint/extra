defmodule Kernel.ExtraTest do
  use ExUnit.Case, async: true
  use PropCheck

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

      defbang only_even: 1, only_odd: 1
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
  end
end
