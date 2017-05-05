defmodule Enum.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Enum.Extra

  describe "each_or_error/2" do
    test "returns :ok if the fn is okay" do
      result =
        Enum.Extra.each_or_error([1, 2, 3], fn _ ->
          send self(), :called
          :ok
        end)

      assert result == :ok

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "returns an error if it is found" do
      result =
        Enum.Extra.each_or_error([1, 2, 3], fn _ ->
          send self(), :called
          {:error, :failure}
        end)

      assert result == {:error, :failure}

      assert_received :called
      refute_received :called
    end
  end
end
