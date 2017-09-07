defmodule File.Extra do
  @moduledoc """
  Extensions to the standard library's `File` module.

  """


  @doc """
  Ensures that there is a directory pointed to by `path`. Creates the directory if necessary.

  """
  @spec ensure_dir(Path.t) :: :ok | no_return
  def ensure_dir(path) do
    case File.dir?(path) do
      true  -> :ok
      false -> File.mkdir_p!(path)
    end
  end


  @doc """
  Asserts that a provided `path` exists on a filesystem. Raises if it does not
  exist.

  ## Example

  iex> File.Extra.assert_exists!("/etc/hosts")
  :ok

  """
  @spec assert_exists!(Path.t) :: :ok | no_return
  def assert_exists!(path) do
    if File.exists?(path) do
      :ok
    else
      raise(File.Error, reason: :enoent, action: "find file", path: path)
    end
  end
end
