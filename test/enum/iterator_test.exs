defmodule Enum.IteratorTest do
  use ExUnit.Case

  alias Enum.Iterator


  describe "Iterator" do
    setup do
      %Iterator{} = iter =
        Iterator.new([1, 2, 3])

      {:ok, iter: iter}
    end

    test "new/1 stores the original Enumerable", %{iter: iter} do
      assert iter.enum == [1, 2, 3]
    end

    test "next/1 allows traversal of the enumerable", %{iter: iter} do
      assert {:ok, 1, iter} =
        Iterator.next(iter)

      assert {:ok, 2, iter} =
        Iterator.next(iter)

      assert {:ok, 3, iter} =
        Iterator.next(iter)

      assert {:error, :done} =
        Iterator.next(iter)
    end

    test "Enumerable implementation", %{iter: iter} do
      assert 3 == Enum.count(iter)

      {:ok, _, iter} =
        Iterator.next(iter)

      assert 2 == Enum.count(iter)

      assert [3, 4] == Enum.map(iter, &(&1 + 1))
    end
  end
end
