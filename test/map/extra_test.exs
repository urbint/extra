defmodule Map.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Map.Extra

  describe "Map.Extra.each_or_error/2" do
    test "returns :ok if the fn is okay" do
      map =
        %{a: 1, b: 2, c: 3}

      result =
        Map.Extra.each_or_error(map, fn {key, val} ->
          send self(), :called

          {:ok, 2*val}
        end)

      assert result == {:ok, %{a: 2, b: 4, c: 6}}

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "returns an error if it is found" do
      map =
        %{a: 1, b: 2, c: 3}

      result =
        Map.Extra.each_or_error(map, fn {key, val} ->
          send self(), :called
          {:error, :failure}
        end)

      assert result == {:error, :failure}

      assert_received :called
      refute_received :called
    end
  end
end
