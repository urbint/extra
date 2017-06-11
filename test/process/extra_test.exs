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

  describe "nearest/2" do
    test "returns nothing on isolate processes" do
      assert Enum.into(Process.Extra.nearest(self()), []) == []
    end

    test "returns linked processes" do
      child =
        spawn_link(fn ->
          receive do
            _ -> :ok
          end
        end)

      assert Enum.into(Process.Extra.nearest(self()), []) == [child]
    end

    test "returns monitor processes" do
      {child, _ref} =
        spawn_monitor(fn ->
          receive do
            _ -> :ok
          end
        end)

      assert Enum.into(Process.Extra.nearest(self()), []) == [child]
    end
  end


  defp spawn_and_monitor do
    spawn_monitor(fn ->
      receive do
        _ -> :ok
      end
    end)
    |> elem(0)
  end

  defp assert_process_exit_with_reason(pid, reason) do
    assert_receive {:DOWN, _ref, :process, ^pid, ^reason}
  end
end
