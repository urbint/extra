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
  }

  defstruct [
    port: nil,
    queue: :queue.new(),
    receiver: nil,
    running: true,
    pending_demand: 0,
  ]



  #########################################################
  # Public API
  #########################################################

  @doc """
  Starts the `CmdStreamer` enumerable by wrapping `cmd` and forwarding `args` to it.

  """
  @spec start(binary, [binary]) :: pid
  def start(cmd, args) do
    receiver =
      self()

    cmd_string =
      [cmd | args] |> Enum.join(" ")

    spawn(fn ->
      port =
        Port.open({:spawn, cmd_string}, [{:line, 20_000}, :binary, :exit_status])

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
  defp loop(%CmdStreamer{receiver: receiver, port: port} = state) do
    receive do
      {^port, {:data, {:eol, line}}} ->
        state
        |> send_or_buffer_line(line)
        |> loop()

      {^port, {:exit_status, 0}} ->
        state =
          %{state | running: false}

        if state.pending_demand > 0 do
          send_receiver(state, :done)
        else
          state
        end
        |> loop()

      {^port, {:exit_status, code}} ->
        send_receiver(state, {:error, code})

      {^receiver, :next_line} ->
        state
        |> send_next_line_or_track_demand
        |> loop()
    end
  end


  @spec send_or_buffer_line(t, binary) :: t
  defp send_or_buffer_line(%CmdStreamer{} = state, line) do
    if state.pending_demand > 0 do
      %{state | pending_demand: state.pending_demand - 1}
      |> send_receiver({:line, line})
    else
      %{state| queue: :queue.in(line, state.queue)}
    end
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
