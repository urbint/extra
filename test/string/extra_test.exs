defmodule String.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest String.Extra

  alias String.Extra


  describe "titlecase/1" do
    test "works with a simple string" do
      assert Extra.titlecase("my weird string") ==
        "My Weird String"
    end

    test "works with hyphenated and underscored string" do
      assert Extra.titlecase("my_weird-word") ==
        "My Weird-Word"
    end

    test "works with ClassCase strings" do
      assert Extra.titlecase("ClassCase") ==
        "Class Case"
    end
  end


  describe "snakecase/1" do
    test "works with a simple string" do
      assert Extra.snakecase("my weird string.") ==
        "my_weird_string"
    end

    test "works with hyphenated and underscored string" do
      assert Extra.snakecase("my_weird-word") ==
        "my_weird_word"
    end

    test "works with ClassCase strings" do
      assert Extra.snakecase("ClassCase") ==
        "class_case"
    end
  end


  describe "escape_digits/1" do
    test "works on inputs containing exclusively digits" do
      assert Extra.escape_digits("1234") == ~S/\1\2\3\4/
    end

    test "works on inputs containing more than digits" do
      assert Extra.escape_digits("My phone number is 1234")
        == ~S/My phone number is \1\2\3\4/
    end
  end


  describe "unescape_digits/1" do
    test "works on inputs containing exclusively digits" do
      assert Extra.unescape_digits(~S/\1\2\3\4/) == "1234"
    end

    test "works on inputs containing more than digits" do
      assert Extra.unescape_digits(~S/My phone number is \1\2\3\4/)
        == "My phone number is 1234"
    end
  end
end
