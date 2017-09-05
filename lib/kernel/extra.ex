defmodule Kernel.Extra do
  @moduledoc """
  Extensions to the standard library's Kernel module.

  """

  @doc """
  Coerces values into booleans.

  ## Examples

    iex> import Kernel.Extra
    ...> 12 |> boolean()
    true

    iex> import Kernel.Extra
    ...> nil |> boolean()
    false

  """
  @spec boolean(any) :: boolean
  def boolean(x),
    do: if x, do: true, else: false

  @doc """
  Define a "banged" version of the given function/arities in the current module, which unwrap return
  cases of the form `{:ok, result} | {:error, reason} | :error`, returning `result` in the success
  case and throwing an `ArgumentError` in the error cases.

  Functions are specified as keywords mapping function name to arity, just like the arguments to
  `defoverridable` or `import`'s `:from` option

  import

    defmodule MyModule do
      def only_even(x) when Integer.is_even(x), do: {:ok, x}
      def only_even(_), do: {:error, "not even"}

      defbang only_even: 1
    end
  """
  @spec defbang([{atom, pos_integer}]) :: Macro.t
  defmacro defbang(functions) do
    Enum.map functions, fn {fname, arity} ->
      banged =
        :"#{fname}!"

      args =
        Macro.generate_arguments(arity, __MODULE__)

      quote do
        @dialyzer {:no_match, [{unquote(banged), unquote(arity)}]}

        @doc """
        Calls `#{unquote(fname)}`, unwrapping `{:ok, result}` tuples and throwing an `ArgumentError`
        in the case of a failure.

        See also: `Kernel.Extra.defbang`
        """
        def unquote(banged)(unquote_splicing(args)) do
          case unquote(fname)(unquote_splicing(args)) do
            {:ok, result} -> result
            {:error, msg} -> raise ArgumentError, msg
            :error        -> raise ArgumentError
          end
        end
      end
    end
  end
end
