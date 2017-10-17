defmodule ETS.Extra.Guards do
  @moduledoc """
  Guard macros for ETS tables.

  """

  @doc """
  Returns true if the given term *could* refer to an ETS table.

  Allowed in match guards.

  """
  defmacro is_table(term) do
    quote do: is_atom(unquote(term)) or is_reference(unquote(term))
  end
end



defmodule ETS.Extra do
  @moduledoc """
  Utility functions for dealing with ETS tables.

  """

  import ETS.Extra.Guards

  @type table :: atom | reference


  @doc """
  Stream all keys from the given ETS table.

  ## Examples

      iex> table = :ets.new(:my_table, [])
      iex> :ets.insert(table, {:foo, 1})
      iex> :ets.insert(table, {:bar, 2})
      iex> ETS.Extra.stream_keys(table) |> Enum.to_list()
      [:bar, :foo]

  """
  @spec stream_keys(table) :: Enum.t
  def stream_keys(table) when is_table(table) do
    Stream.resource(
      fn -> :ets.first(table) end,
      fn
        :"$end_of_table" -> {:halt, nil}
        key              -> {[key], :ets.next(table, key)}
      end,
      fn _acc -> :ok end
    )
  end


  @doc """
  Stream objects from the given ETS table as `{key, value}` pairs.

  ## Examples

      iex> table = :ets.new(:my_table, [])
      iex> :ets.insert(table, {:foo, 1})
      iex> :ets.insert(table, {:bar, 2})
      iex> ETS.Extra.stream(table) |> Enum.to_list()
      [bar: 2, foo: 1]

  """
  @spec stream(table) :: Enum.t
  def stream(table) when is_table(table) do
    stream_keys(table)
    |> Stream.map(& :ets.lookup(table, &1) |> hd())
  end


  @doc """
  Copy all the data in the given ETS table to a new ETS table with the given name and options.

  Given options are passed-through unchanged to `:ets.new`.

  ## Examples

      iex> original_table = :ets.new(:my_table, [])
      iex> :ets.insert(original_table, {:foo, 1})
      iex> :ets.insert(original_table, {:bar, 2})
      iex> ETS.Extra.stream(original_table) |> Enum.to_list()
      [bar: 2, foo: 1]
      iex> new_table = ETS.Extra.copy(original_table, :new_table)
      iex> ETS.Extra.stream(original_table) |> Enum.to_list()
      [bar: 2, foo: 1]
      iex> ETS.Extra.stream(new_table) |> Enum.to_list()
      [bar: 2, foo: 1]

  """
  @spec copy(atom | :ets.tid, target_name, options) :: :ets.tid | atom
    when target_name: atom,
         options: [option],
         option:
           type |
           access |
           :named_table |
           {:keypos, pos} |
           {:heir, pid, heir_data} |
           {:heir, :none} |
           tweaks,
         type: :bag | :compressed | :duplicate_bag | :ordered_set | :set,
         access: :private | :protected | :public,
         tweaks:
           {:write_concurrency, boolean} |
           {:read_concurrency, boolean} |
           :compressed,
         pos: pos_integer,
         heir_data: term
  def copy(source, destination, options \\ []) do
    table =
      :ets.new(destination, options)

    stream(source) |> Enum.each(&:ets.insert(table, &1))

    table
  end

end
