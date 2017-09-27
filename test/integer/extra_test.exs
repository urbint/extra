defmodule Integer.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Integer.Extra

  test "parse!/2" do
    assert 123 == "123" |> Integer.Extra.parse!()

    assert [123, 456] == ["123", "456"] |> Enum.map(&Integer.Extra.parse!/1)
  end

end
