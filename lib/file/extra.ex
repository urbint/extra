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
end
