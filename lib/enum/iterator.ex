defmodule Enum.Iterator do
  @moduledoc """
  Struct for enumerating an `enum` and having a stateful struct to consume items
  one at a time.


  Note that the iterator implements Enumerable itself and will emit all items
  that have not yet been consumed.

  """

  alias __MODULE__

  ############################################################
  # Type and Struct Definition
  ############################################################

  @type t :: %__MODULE__{
    enum: Enum.t,
    next: Enumerable.continuation
  }

  @enforce_keys [:next, :enum]
  defstruct [:next, :enum]



  ############################################################
  # Public API
  ############################################################

  @doc """
  Returns an `Iterator.t` for the provided `enum`.

  """
  @spec new(Enum.t) :: t
  def new(enum) do
    %Iterator{
      enum: enum,
      next: &Enumerable.reduce(enum, &1, fn item, acc -> {:suspend, {item, acc}} end)
    }
  end



  @doc """
  Returns the next item in the `iterator`, as well as a new `iterator` represented the
  new offset position.

  If there are no items left, a `{:error, :done}` tuple will be returned.

  """
  @spec next(t) :: {:ok, any, t} | {:error, :done} | {:error, :halted}
  def next(%Iterator{next: next} = iterator) do
    case next.({:cont, []}) do
      {:suspended, {item, []}, next} -> {:ok, item, %Iterator{iterator | next: next}}
      {:done, []}                    -> {:error, :done}
      {:halted, []}                  -> {:error, :halted}
    end
  end

  @doc """
  Halts the underlying enumerable.

  This is useful for things like closing file descriptors and sockets. In most cases,
  it will cause subsequent calls to `next/1` to return `{:error, :halted}`.

  """
  @spec halt(t) :: :ok
  def halt(%Iterator{next: next}) do
    {:halted, []} =
      next.({:halt, []})

    :ok
  end

  defimpl Enumerable do
    def count(_), do: {:error, __MODULE__}
    def member?(_, _), do: {:error, __MODULE__}

    def reduce(%Iterator{next: next}, {:halt, acc}, _fun) do
      next.({:halt, acc})
    end
    def reduce(iter, {:cont, acc}, fun) do
      case Iterator.next(iter) do
        {:ok, val, iter} -> reduce(iter, fun.(val, acc), fun)
        {:error, :done}  -> {:done, acc}
      end
    end
  end
end
