defmodule Behaviour.ExtraTest do
  use ExUnit.Case

  describe "assert_impl!/2 and implements?/2" do
    defmodule Behave do
      @callback thing(any, any) :: boolean
    end

    defmodule ModA do
      def thing(_x, _y), do: true
    end

    defmodule ModB, do: nil

    test "assert_impl!/2 returns :ok if all functions are implemented" do
      assert :ok == Behaviour.Extra.assert_impl!(Behave, ModA)
    end

    test "assert_impl!/2 raises when any function is not implemented" do
      assert_raise ArgumentError, fn ->
        Behaviour.Extra.assert_impl!(Behave, ModB)
      end
    end

    test "implements?/2 returns true if all functions are implemented" do
      assert true == Behaviour.Extra.implements?(Behave, ModA)
    end

    test "implements?/2 returns false if any function is not implemented" do
      assert false == Behaviour.Extra.implements?(Behave, ModB)
    end
  end
end
