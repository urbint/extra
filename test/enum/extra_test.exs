defmodule Enum.ExtraTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Enum.Extra

  describe "Enum.Extra.each_or_error/2" do
    test "returns :ok if the fn is okay" do
      result =
        Enum.Extra.each_or_error([1, 2, 3], fn _ ->
          send self(), :called
          :ok
        end)

      assert result == :ok

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "returns an error if it is found" do
      result =
        Enum.Extra.each_or_error([1, 2, 3], fn _ ->
          send self(), :called
          {:error, :failure}
        end)

      assert result == {:error, :failure}

      assert_received :called
      refute_received :called
    end
  end

  describe "Enum.Extra.map_or_error/2" do
    test "works for maps" do
      map =
        %{a: 1, b: 2, c: 3}

      result =
        Enum.Extra.map_or_error(map, fn {key, val} ->
          send self(), :called

          {:ok, {key, 2 * val}}
        end)

      assert result == {:ok, %{a: 2, b: 4, c: 6}}

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "works for a keyword list" do
      kw =
        [a: 1, b: 2, c: 3]

      result =
        Enum.Extra.map_or_error(kw, fn {key, val} ->
          send self(), :called

          {:ok, {key, 2 * val}}
        end)

      assert result == {:ok, [a: 2, b: 4, c: 6]}

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "returns a map if specified" do
      kw =
        [a: 1, b: 2, c: 3]

      result =
        Enum.Extra.map_or_error(kw, fn {key, val} ->
          send self(), :called

          {:ok, {key, 2 * val}}
        end, into: %{})

      assert result == {:ok, %{a: 2, b: 4, c: 6}}

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "works for a list" do
      list =
        [1, 2, 3]

      result =
        Enum.Extra.map_or_error(list, fn val ->
          send self(), :called

          {:ok, 2 * val}
        end)

      assert result == {:ok, [2, 4, 6]}

      assert_received :called
      assert_received :called
      assert_received :called
    end

    test "returns an error if it is found" do
      map =
        %{a: 1, b: 2, c: 3}

      result =
        Enum.Extra.map_or_error(map, fn {_key, _val} ->
          send self(), :called
          {:error, :failure}
        end)

      assert result == {:error, :failure}

      assert_received :called
      refute_received :called
    end
  end

  describe "index_by/2" do
    test "indexes elements using the indexer function" do
      cast =
        [%{name: "Jerry"}, %{name: "George"}, %{name: "Kramer"}]

      assert Enum.Extra.index_by(cast, &Map.get(&1, :name)) ==
        %{"Jerry"  => %{name: "Jerry"},
          "George" => %{name: "George"},
          "Kramer" => %{name: "Kramer"},
         }
    end

    test "last writer wins" do
      cast =
        [%{fname: "Jerry",  lname: "Seinfeld"},
         %{fname: "George", lname: "Constanza"},
         %{fname: "Cosmo",  lname: "Kramer"},
         %{fname: "Jerry",  lname: "Zeinfeld"},
        ]

      assert Enum.Extra.index_by(cast, &Map.get(&1, :fname)) ==
        %{"George" => %{fname: "George", lname: "Constanza"},
          "Cosmo"  => %{fname: "Cosmo",  lname: "Kramer"},
          "Jerry"  => %{fname: "Jerry",  lname: "Zeinfeld"},
         }
    end
  end

  describe "count_by/2" do
    test "returns counts per value returned by the value func" do
      cast =
        [%{fname: "Jerry",  lname: "Seinfeld", role: "star"},
         %{fname: "George", lname: "Constanza", role: "costar"},
         %{fname: "Cosmo",  lname: "Kramer", role: "costar"},
         %{fname: "Jerry",  lname: "Zeinfeld", role: "alias"},
        ]

      assert Enum.Extra.count_by(cast, & &1.role) ==
        %{"alias" => 1, "costar" => 2, "star" => 1}
    end
  end


  describe "fold/3" do
    test "reduces properly" do
      names =
        [:jerry, :george, :elaine, :cosmo]

      init =
        []

      folded =
        Enum.Extra.fold(init, names, fn name, acc -> [name | acc] end)

      assert folded == Enum.reverse(names)
    end

    test "handles an empty list" do
      init =
        {:cosmo, "Kramer"}

      folded =
        Enum.Extra.fold(init, [], fn _, _ -> :never_run end)

      assert folded == init
    end
  end

  describe "longest/1" do
    test "does not unnecessarily consume items" do
      pid =
        self()

      enum_a =
        [1, 2, 3, 4, 5]
        |> Stream.each(&send(pid, &1))

      enum_b =
        [1, 2]

      longest =
        Enum.Extra.longest([enum_a, enum_b])

      assert longest == enum_a

      assert_received 1
      assert_received 2
      assert_received 3
      refute_received 4
      refute_received 5
    end
  end
end
