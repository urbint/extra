defmodule Kernel.ExtraTest do
  use ExUnit.Case, async: true
  use PropCheck

  import Kernel.Extra

  @falsy_vals [false, nil]


  describe "boolean" do
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
end
