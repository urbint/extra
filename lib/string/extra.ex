defmodule String.Extra do
  @moduledoc """
  Extensions to the built-in `String` module.

  """

  @single_digit_regex ~r/\d/
  @escaped_digit_regex ~r/\\(\d)/
  @classcase_split_regex ~r/(?<![A-Z])(?=[A-Z])/


  @doc """
  Converts the provided input into titlecase.

  It will also convert ClassCase to Title Case.

  ## Examples

      iex> String.Extra.titlecase("this is a test.")
      "This Is A Test."

      iex> String.Extra.titlecase("ThisModule")
      "This Module"

  """
  @spec titlecase(String.t) :: String.t
  def titlecase(string) do
    Regex.replace(~r/_/, string, " ")
    |> String.split
    |> Enum.flat_map(&String.split(&1, @classcase_split_regex))
    |> Stream.map(&capitalize/1)
    |> Enum.join(" ")
  end


  @doc """
  Converts the provided input into snakecase.

  It will strip periods and commas.

  ## Examples

      iex> String.Extra.snakecase("this is a test.")
      "this_is_a_test"

      iex> String.Extra.snakecase("ThisModule")
      "this_module"

  """
  @spec snakecase(String.t) :: String.t
  def snakecase(string) do
    string
    |> titlecase()
    |> String.replace(~r/[,.]/, "")
    |> String.replace(~r/[-\s]/, "_")
    |> String.downcase
  end


  @doc """
  Escapes digits within a provided string.

  ## Examples

      iex> String.Extra.escape_digits("1234")
      ~S/\\1\\2\\3\\4/

  """
  @spec escape_digits(String.t) :: String.t
  def escape_digits(input) when is_binary(input) do
    Regex.replace(@single_digit_regex, input, fn(digit) ->
      "\\" <> digit
    end)
  end


  @doc """
  Unescapes digits within a provided string.

  ## Examples

      iex> String.Extra.unescape_digits(~S/\\1\\2\\3\\4/)
      "1234"

  """
  @spec unescape_digits(String.t) :: String.t
  def unescape_digits(input) when is_binary(input) do
    Regex.replace(@escaped_digit_regex, input, fn(_, match) -> match end)
  end


  @doc """
  Dedupes the spaces within `input`.

      iex> String.Extra.dedupe_spaces("Hello    world   ")
      "Hello world"

  """
  @spec dedupe_spaces(String.t) :: String.t
  def dedupe_spaces(input) do
    String.replace(input, ~r/\s{2,}/, " ")
    |> String.trim()
  end


  @doc """
  Wraps `input` with `wrapper`.

  ## Examples

      iex> String.Extra.wrap_with("test", "\b")
      "\btest\b"

  """
  @spec wrap_with(String.t, String.t) :: String.t
  def wrap_with(input, wrapper) when is_binary(input) and is_binary(wrapper) do
    wrapper <> input <> wrapper
  end



  #########################################################################################
  # Private Helpers
  #########################################################################################

  # a version of capitalize that treats dashes as word delimiters
  @spec capitalize(String.t) :: String.t
  defp capitalize(input) do
    do_capitalize(input, {false, ""})
  end


  @spec do_capitalize(String.t, {inside_word? :: boolean, String.t}) :: String.t
  defp do_capitalize("", {_, acc}),
    do: acc

  defp do_capitalize(<<"-", xs::binary>>, {true, acc}),
    do: do_capitalize(xs, {false, acc <> "-"})

  defp do_capitalize(<<x::binary-size(1), xs::binary>>, {false, acc}),
    do: do_capitalize(xs, {true, acc <> String.upcase(x)})

  defp do_capitalize(<<x::binary-size(1), xs::binary>>, {true, acc}),
    do: do_capitalize(xs, {true, acc <> String.downcase(x)})

end
