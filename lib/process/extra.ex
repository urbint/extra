defmodule Process.Extra do
  @moduledoc """
  Extensions to the standard library's `Process` module.

  """

  @doc """
  Exits the specified `pid_or_atom` with the provided `:reason`.

  This function is similar to `Process.kill/2` with the following differences:

  It accepts an atom, in which case it will attempt to resolve the module via `Process.whereis/1`,
  and if it is unable to resolve it will function as a no-op.

  """
  @spec exit(atom | pid, reason :: term) :: true
  def exit(atom, reason) when is_atom(atom) do
    case Process.whereis(atom) do
      nil                  -> true
      pid when is_pid(pid) -> exit(pid, reason)
    end
  end

  def exit(pid, reason) when is_pid(pid) do
    Process.exit(pid, reason)
  end

  @doc """
  Returns a stream of nearest neighbors closest to the `pid` via traversal.

  Which process relationships to traverse is defined by the options below.

  ## Options

    * `:links`    - `boolean` - whether to include linked processes. Default: `true`.
    * `:monitors` - `boolean` - whether to include monitored processes. Default: `true`.

  """
  @spec nearest(pid, keyword) :: Enum.t
  def nearest(pid, opts \\ []) when is_pid(pid) and is_list(opts) do
    traverse_fn =
      build_traverse_fn(opts)

    Stream.resource(
      fn -> do_nearby_init(traverse_fn, pid) end,
      &do_nearby_next/1,
      fn _ -> :ok end
    )
  end

  defp do_nearby_init(traverse_fn, pid), do: {traverse_fn.(pid), MapSet.new, MapSet.new([pid]), traverse_fn}

  defp do_nearby_next({[pid | rest], current_layer, already_checked, traverse_fn}) do
    {[pid], {rest, MapSet.put(current_layer, pid), MapSet.put(already_checked, pid), traverse_fn}}
  end

  defp do_nearby_next({[], current_layer, already_checked, traverse_fn}) do
    current_layer
    |> Stream.flat_map(traverse_fn)
    |> Enum.into(MapSet.new)
    |> MapSet.difference(already_checked)
    |> Enum.into([])
    |> case do
         []    -> {:halt, :ok}
         pids  -> {[], {pids, [], already_checked, traverse_fn}}
       end
  end


  @spec build_traverse_fn(keyword) :: (pid -> [pid])
  defp build_traverse_fn(opts) do
    nearby_atoms =
      [:links, :monitors]
      |> Enum.reject(&(Keyword.get(opts, &1) == false))

    fn pid ->
      nearby_atoms
      |> Enum.flat_map(&Process.info(pid, &1) |> extract_processes())
    end
  end

  defp extract_processes({:monitors, items}),
    do: items |> Stream.filter(&match?({:process, _}, &1)) |> Stream.map(&elem(&1, 1))
  defp extract_processes({:links, items}),
    do: items |> Stream.filter(&is_pid/1)
end
