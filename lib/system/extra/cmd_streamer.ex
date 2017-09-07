defmodule System.Extra.CmdStreamer do
  @moduledoc """
  Module allowing Enumerables to be constructed around Shell commands.

  """

  alias __MODULE__



  #########################################################
  # Types
  #########################################################

  @opaque t :: %__MODULE__{
    port: port,
    queue: :queue.queue,
    receiver: pid,
    running: boolean,
    pending_demand: non_neg_integer,
    buffer: binary,
  }

  defstruct [
    port: nil,
    queue: :queue.new(),
    receiver: nil,
    running: true,
    pending_demand: 0,
    buffer: "",
  ]



  #########################################################
  # Public API
  #########################################################

  @doc """
  Starts the `CmdStreamer` enumerable by wrapping `cmd` and forwarding `args` to it.

  ## Options

    * `line_length`: `pos_integer`. Maximum size of message sent between the command `Port` and the
      `CmdStreamer`. Defaults to `20_000`.

  """
  @spec start(binary, [binary], keyword) :: pid
  def start(cmd, args, opts) do
    receiver =
      self()

    line_length =
      Keyword.get(opts, :line_length, 20_000)

    spawn(fn ->
      port =
        Port.open({:spawn_executable, System.find_executable(cmd)},
          [{:line, line_length}, {:args, args}, :binary, :exit_status])

      state =
        %CmdStreamer{port: port, receiver: receiver}

      loop(state)
    end)
  end


  @doc """
  Requests the most recent output from the `CmdStreamer`.

  """
  @spec get_line(pid) :: {:line, binary} | {:error, non_neg_integer} | :done
  def get_line(pid) do
    send(pid, {self(), :next_line})
    receive do
      {^pid, msg} -> msg
    end
  end



  #########################################################
  # Private Helpers
  #########################################################

  @spec loop(t) :: no_return
  defp loop(%CmdStreamer{receiver: receiver, port: port, buffer: buffer} = state) do
    receive do
      {^port, {:data, {:noeol, line}}} ->
        %{state | buffer: buffer <> line}
        |> loop()

      {^port, {:data, {:eol, line}}} ->
        state
        |> send_or_buffer_line(line)
        |> loop()

      {^port, {:exit_status, 0}} ->
        state =
          %{state | running: false}

        send_receiver(state, :done)
        |> loop()

      {^port, {:exit_status, code}} ->
        state =
          %{state | running: false}

        send_receiver(state, {:error, code})

      {^receiver, :next_line} ->
        state
        |> send_next_line_or_track_demand()
        |> loop()
    end
  end


  @spec send_or_buffer_line(t, binary) :: t
  defp send_or_buffer_line(
    %CmdStreamer{pending_demand: 0, queue: queue, buffer: buffer} = state, line) do
    %{state| queue: :queue.in(buffer <> line, queue), buffer: ""}
  end

  defp send_or_buffer_line(
    %CmdStreamer{pending_demand: pending_demand, buffer: buffer} = state, line) do
    %{state | pending_demand: pending_demand - 1, buffer: ""}
    |> send_receiver({:line, buffer <> line})
  end


  @spec send_next_line_or_track_demand(t) :: t
  defp send_next_line_or_track_demand(%CmdStreamer{running: running?, queue: queue} = state) do
    case :queue.out(queue) do
      {{:value, line}, queue} ->
        %{state | queue: queue}
        |> send_receiver({:line, line})

      {:empty, _queue} ->
        if running? do
          %{state | pending_demand: state.pending_demand + 1}
        else
          send_receiver(state, :done)
        end
    end
  end


  @spec send_receiver(t, {:line, binary} | :done | {:error, non_neg_integer}) :: t
  defp send_receiver(%CmdStreamer{receiver: receiver} = state, msg) do
    send(receiver, {self(), msg})
    state
  end

end
