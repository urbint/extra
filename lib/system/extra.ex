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

  ## Examples

    iex> System.Extra.assert_executable!("mix")
    :ok

  """
  @spec assert_executable!(binary) :: :ok | no_return
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

  Will raise an error under two conditions:

    * the command exits with a non-zero exit code

  ## Options

    * `line_length`: Forwarded to `CmdStreamer.start/3`. See docs for more information.


  ## Examples

    iex> System.Extra.stream_cmd("echo", ["hello"]) |> Enum.take(1)
    ["hello"]

  """
  @spec stream_cmd(binary, [binary]) :: Enum.t
  def stream_cmd(command, args \\ [], opts \\ []) do
    Stream.resource(
      fn -> CmdStreamer.start(command, args, opts) end,
      &do_stream_cmd/1,
      &do_stream_exit/1
    )
  end



  #########################################################
  # Private Helpers
  #########################################################

  @spec do_stream_cmd(pid) :: {[element], acc} | {:halt, acc} | no_return
  defp do_stream_cmd(pid) do
    case CmdStreamer.get_line(pid) do
      {:line, line}  -> {[line], pid}
      {:error, code} -> raise "Non-zero exit code: #{code}"
      :done          -> {:halt, pid}
    end
  end


  @spec do_stream_exit(pid) :: true
  defp do_stream_exit(pid) do
    Process.exit(pid, :kill)
  end

end
