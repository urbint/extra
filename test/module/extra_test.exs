defmodule Module.ExtraTest do
  use ExUnit.Case

  describe "assert_exists!/1" do
    defmodule Mod, do: nil

    test "returns :ok if the module exists" do
      assert :ok == Module.Extra.assert_exists!(Mod)
    end

    test "raises if the module does not exist" do
      assert_raise ArgumentError, fn ->
        Module.Extra.assert_exists!(DoesNotExist)
      end
    end
  end
end
