defmodule File.ExtraTest do
  use ExUnit.Case, async: true

  @test_dir Path.join("/tmp/.urbint_tests/", "file_extra")

  describe "ensure_dir/1" do
    setup do
      path =
        Path.join(@test_dir, "miscellaneous")

      on_exit fn ->
        case File.exists?(path) do
          true  -> File.rm_rf!(path)
          false -> :ok
        end
      end

      {:ok, %{path: path}}
    end

    test "creates a directory when one does not exist", %{path: path} do
      refute File.exists?(path)

      File.Extra.ensure_dir(path)

      assert File.exists?(path)
      assert File.dir?(path)
    end

    test "does not create a directory if one already exists", %{path: path} do
      # setup
      refute File.exists?(path)
      File.mkdir_p!(path)
      assert File.exists?(path)

      File.Extra.ensure_dir(path)

      assert File.exists?(path)
      assert File.dir?(path)
    end

  end
end
