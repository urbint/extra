defmodule Behaviour.ExtraTest do
  use ExUnit.Case

  describe "assert_impl!/2" do
    defmodule Behave do
      @callback thing(any, any) :: boolean
    end

    defmodule ModA do
      def thing(_x, _y), do: true
    end

    defmodule ModB, do: nil

    test "returns :ok if all functions are implemented" do
      assert :ok == Behaviour.Extra.assert_impl!(Behave, ModA)
    end

    test "raises when any function is not implemented" do
      assert_raise ArgumentError, fn ->
        Behaviour.Extra.assert_impl!(Behave, ModB)
      end
    end
  end
end
