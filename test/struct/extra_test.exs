defmodule Struct.ExtraTest do
  use ExUnit.Case, async: true

  import ShorterMaps

  defmodule CreditCard do
    defstruct [
      number: :default,
      cvv: :default
    ]
  end


  describe "drop/2" do
    setup do
      input =
        %CreditCard{
          number: "1234-5678-9101-1121",
          cvv: "123",
        }

      {:ok, ~M{input}}
    end

    test "does not work for non-structs", ~M{input} do
      assert_raise FunctionClauseError, fn ->
        Struct.Extra.drop(%{}, [])
      end
    end

    test "replaces dropped fields with their default values", ~M{input} do
      assert Struct.Extra.drop(input, [:number, :cvv]) ==
        %CreditCard{number: :default, cvv: :default}
    end
  end
end
