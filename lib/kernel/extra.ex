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


  @doc """
  Define a type union, module attribute, public function, and guard macro for a named list of
  supported values all in one go.

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

        defmacro is_flavor(x) do
          quote do: unquote(x) in unquote(@flavors)
        end
      end

  """
  @spec defunion(name :: atom, [atom]) :: Macro.t
  defmacro defunion(name, values) do
    type_rhs =
      Enum.reduce(values, fn (x, acc) -> quote do: unquote(x) | unquote(acc) end)

    # XXX use real pluralization, if it's ever necessary
    plural =
      :"#{name}s"

    quote do
      @type unquote(Macro.var(name, nil)) :: unquote(type_rhs)

      Module.put_attribute __MODULE__, unquote(plural), unquote(values)

      @doc """
      Returns a list of all valid #{unquote(plural)}.

      """
      @spec unquote(:"__union_#{plural}__")() :: list()
      def unquote(:"__union_#{plural}__")(), do: unquote(values)

      @doc """
      Returns true if the given value is a valid #{unquote(name)}. Can be used in guards.

      """
      defmacro unquote(:"is_#{name}")(x), do: {:in, [], [x, unquote(values)]}
    end
  end

end
