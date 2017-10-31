defmodule Binary.Extra do
  @moduledoc """
  Module for useful functions for binaries and bitstrings.

  """


  @doc """
  Pad the given binary with the given byte (0-255) at the beginning such that it is the given
  length.

  Compare to `String.pad_leading`, except this function does not count unicode codepoints as a
  single character:

      iex> String.pad_leading("∀x∈ℝ", 12, "a")
      "aaaaaaaa∀x∈ℝ"

      iex> Binary.Extra.pad_leading("∀x∈ℝ", 12, ?a)
      "aa∀x∈ℝ"

  """
  @spec pad_leading(binary, non_neg_integer, byte) :: binary
  def pad_leading(binary, target_size, pad_with \\ 0) when pad_with >= 0 and pad_with <= 255 do
    needed_chars =
      target_size - byte_size(binary)

    case needed_chars do
      0 ->
        binary
      _ ->
        make_padding(pad_with, needed_chars) <> binary
    end
  end


  @doc """
  Pad the given binary with the given byte (0-255) at the beginning such that it is the given
  length.

  Compare to `String.pad_trailing`, except this function does not count unicode codepoints as a
  single character:

      iex> String.pad_trailing("∀x∈ℝ", 12, "a")
      "∀x∈ℝaaaaaaaa"

      iex> Binary.Extra.pad_trailing("∀x∈ℝ", 12, ?a)
      "∀x∈ℝaa"

  """
  @spec pad_trailing(binary, non_neg_integer, byte) :: binary
  def pad_trailing(binary, target_size, pad_with \\ 0) when pad_with >= 0 and pad_with <= 255 do
    needed_chars =
      target_size - byte_size(binary)

    case needed_chars do
      0 ->
        binary
      _ ->
        binary <> make_padding(pad_with, needed_chars)
    end
  end



  ################################################################################
  # Private Helpers
  ################################################################################

  @spec make_padding(byte, non_neg_integer) :: binary
  defp make_padding(byte, needed) do
    Stream.repeatedly(fn -> byte end)
    |> Enum.take(needed)
    |> :binary.list_to_bin()
  end

end
