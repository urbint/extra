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

    test "does not work for non-structs" do
      assert_raise FunctionClauseError, fn ->
        Struct.Extra.drop(%{}, [])
      end
    end

    test "replaces dropped fields with their default values", ~M{input} do
      assert Struct.Extra.drop(input, [:number, :cvv]) ==
        %CreditCard{number: :default, cvv: :default}
    end
  end


  describe "merge/2" do
    test "overwrites default values in A with non-default values from B" do
      a =
        %CreditCard{number: :default}

      b =
        %CreditCard{number: "1234-5678-9101-1121"}

      expected =
        %CreditCard{number: "1234-5678-9101-1121"}

      assert Struct.Extra.merge(a, b) == expected
    end

    test "does not overwrite non-default values in A with default values from B" do
      a =
        %CreditCard{number: "1234-5678-9101-1121"}

      b =
        %CreditCard{number: :default}

      expected =
        %CreditCard{number: "1234-5678-9101-1121"}

      assert Struct.Extra.merge(a, b) == expected
    end

    test "overwrites non-default values in A with non-default values from B" do
      a =
        %CreditCard{cvv: "1234"}

      b =
        %CreditCard{cvv: "5678"}

      expected =
        %CreditCard{cvv: "5678"}

      assert Struct.Extra.merge(a, b) == expected
    end

    test "overrides A's default values" do
      a =
        %CreditCard{cvv: :default}

      b =
        %CreditCard{cvv: "5678"}

      expected =
        %CreditCard{cvv: "5678"}

      assert Struct.Extra.merge(a, b) == expected
    end
  end

end
