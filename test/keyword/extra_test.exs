defmodule Keyword.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Keyword.Extra

  describe "default/3" do
    test "Uses falsy values when they're supplied by the user" do
      assert Keyword.Extra.default([optional: true, on_error: nil], :on_error, :error) == nil
    end

    test "Uses default values when the user does not supply a value" do
      assert Keyword.Extra.default([optional: true], :on_error, :error) == :error
    end
  end
end
