defmodule MonoidTest do
  use ExUnit.Case, async: true
  use PropCheck
  doctest Monoid
  import Monoid

  describe "monoid laws" do
    property "associativity for Lists" do
      forall {x, y, z} <- {list(), list(), list()} do
        mplus(mplus(x, y), z) == mplus(x, mplus(y, z))
      end
    end

    property "identity for Lists" do
      forall {x, y} <- {list(), list()} do
        id = identity(y)
        mplus(x, id) == x && mplus(id, x) == x
      end
    end

    property "associativity for Maps" do
      forall {x, y, z} <- {map(), map(), map()} do
        mplus(mplus(x, y), z) == mplus(x, mplus(y, z))
      end
    end

    property "identity for Maps" do
      forall {x, y} <- {map(), map()} do
        id = identity(y)
        mplus(x, id) == x && mplus(id, x) == x
      end
    end
  end

  # Generator for Maps
  defp map do
    let keys <- list() do
      let values <- vector(length(keys), any()) do
        Enum.zip keys, values
      end
    end
  end
end
