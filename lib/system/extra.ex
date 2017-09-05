defmodule System.Extra do
  @moduledoc """
  Extensions to the standard library's System module

  """

  alias __MODULE__.CmdStreamer



  #########################################################
  # Types
  #########################################################

  @typep acc :: any
  @typep element :: any



  #########################################################
  # Public API
  #########################################################

  @doc """
  Asserts that the provided path is valid and an executable binary.

  iex> System.Extra.assert_executable!("/usr/local/bin/mix")
  :ok

  """
  @spec assert_executable!(Stream.t) :: :ok | no_return
  def assert_executable!(path) do
    case System.find_executable(path) do
      result when is_binary(result) ->
        :ok

      nil ->
        raise(File.Error, reason: :enoent, action: "find executable", path: path)
    end
  end


  @doc """
  Streams output from a command by line.

  Will raise an error if the command exits with a non-zero exit code.

  Will also error on lines over 20,000 characters long. Don't be that guy.

      iex> System.Extra.stream_cmd("echo", ["hello"]) |> Enum.take(1)
      ["hello"]

  """
  @spec stream_cmd(binary, [binary]) :: Enumerable.t
  def stream_cmd(command, args \\ []) do
    Stream.resource(
      fn -> CmdStreamer.start(command, args) end,
      &do_stream_cmd/1,
      &do_stream_exit/1
    )
  end



  #########################################################
  # Private Helpers
  #########################################################

  @spec do_stream_cmd(pid) :: (acc -> {[element], acc} | {:halt, acc})
  defp do_stream_cmd(pid) do
    case CmdStreamer.get_line(pid) do
      {:line, line}  -> {[line], pid}
      {:error, code} -> raise "Non-zero exit code: #{code}"
      :done          -> {:halt, pid}
    end
  end


  @spec do_stream_exit(pid) :: (acc -> term)
  defp do_stream_exit(pid) do
    Process.exit(pid, :kill)
  end

end
