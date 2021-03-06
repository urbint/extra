defmodule Kernel.Extra do
  @moduledoc """
  Extensions to the standard library's Kernel module.

  """


  @doc """
  Creates a new function where the output of the last function in `functions` is passed into the
  second-to-last function in `functions` and so on until the list is exhausted.

  ## Examples

    iex> import Kernel.Extra
    ...> compose([fn x -> x <> ", world." end, &String.downcase/1]).("HELLO")
    "hello, world."

  """
  def compose(functions) when is_list(functions) do
    reversed =
      :lists.reverse(functions)

    fn input ->
      reversed |> Enum.reduce(input, & &1.(&2))
    end
  end


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

      defmodule MyModule do
        import Kernel.Extra

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
            {:error, msg} -> raise ArgumentError, to_string(msg)
            :error        -> raise ArgumentError
          end
        end
      end
    end
  end


  @doc """
  Define a type union, module attribute, and public function for a named list of supported values
  all in one go.

  Concretely, the following:

      defmodule Quark do
        import Kernel.Extra

        defunion :flavor, [:up, :down, :strange, :charm, :top, :bottom]
      end

  Transforms into essentially the following:

      defmodule Quark do
        import Kernel.Extra

        @flavors [:up, :down, :strange, :charm, :top, :bottom]

        @type flavor :: :up | :down | :strange | :charm | :top | :bottom

        def __union_flavors__, do: @flavors
      end

  """
  @spec defunion(name :: atom, [any]) :: Macro.t
  defmacro defunion(name, values) do
    type_rhs =
      values
      |> Enum.map(&resolve_type/1)
      |> Enum.reduce(fn x, acc -> quote do: unquote(x) | unquote(acc) end)

    # XXX use real pluralization, if it's ever necessary
    plural =
      :"#{name}s"

    quote do
      @type unquote(Macro.var(name, nil)) :: unquote(type_rhs)

      Module.put_attribute(__MODULE__, unquote(plural), unquote(values))

      @doc """
      Returns a list of all valid #{unquote(plural)}.

      """
      @spec unquote(:"__union_#{plural}__")() :: list()
      def unquote(:"__union_#{plural}__")(), do: unquote(values)
    end
  end



  ################################################################################
  # Private Helpers
  ################################################################################

  # Elixir's @type system cannot represent every literal value but it can
  # represent a subset of literal values.
  #
  # Eg the type system recognizes atoms such as :hello so a type annotation like
  # @type :: :hello is valid, but for binary literals such as "hello", we need a
  # type annotation like @type :: binary. `resolve_type/1` finds the nearest,
  # most narrow type for a given `input`.
  defp resolve_type(input) when is_binary(input), do: Macro.var(:binary, Kernel)
  defp resolve_type(input) when is_float(input), do: Macro.var(:float, Kernel)
  defp resolve_type(catchall), do: catchall

end
