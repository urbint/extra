defmodule Map.ExtraTest do
  use ExUnit.Case, async: true


  describe "assert_key!/3" do
    test "raises when the provided map does not have the specified key" do
      assert_raise ArgumentError, fn ->
        Map.Extra.assert_key!(%{first_name: "Jim"}, :last_name)
      end
    end

    test "does not raise when the provided map does has the specified key" do
      assert Map.Extra.assert_key!(%{name: "Jim Jones"}, :name) == :ok
    end
  end

end


defmodule Mod do
  @after_compile __MODULE__

  defmacro __after_compile__(%{module: module}, _bytecode) do
    quote do
      def hello, do: "world"
    end
  end
end
