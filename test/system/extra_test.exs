defmodule System.ExtraTest do
  use ExUnit.Case, async: true
  doctest System.Extra

  describe "assert_executable!/1" do
    test "does not raise when passed existant binaries" do
      assert :ok = System.Extra.assert_executable!("/bin/cat")
    end

    test "raises when passed nonexistant binaries" do
      path = "/bin/not_real"
      f = fn -> System.Extra.assert_executable!(path) end

      assert_raise(File.Error, "could not find executable \"#{path}\": no such file or directory", f)
    end
  end
end
