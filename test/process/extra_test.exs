defmodule Process.ExtraTest do
  use ExUnit.Case, async: true
  doctest Process.Extra


  describe "exit/2" do
    test "handles a registered process" do
      pid =
        spawn_and_monitor()

      Process.register(pid, :my_named_process)

      Process.Extra.exit(:my_named_process, :shutdown)

      assert_process_exit_with_reason(pid, :shutdown)
    end

    test "handles a non-registered process" do
      pid =
        spawn_and_monitor()

      Process.Extra.exit(pid, :shutdown)

      assert_process_exit_with_reason(pid, :shutdown)
    end
  end

  defp spawn_and_monitor do
    pid =
      spawn(fn ->
        receive do
          _ -> :ok
        end
      end)

    Process.monitor(pid)

    pid
  end

  defp assert_process_exit_with_reason(pid, reason) do
    assert_receive {:DOWN, _ref, :process, ^pid, ^reason}
  end
end
