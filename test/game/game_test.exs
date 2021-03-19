defmodule Engine2048.GameTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game

  describe "Game swipes" do
    test "swipe right" do
      board = [
        [0, 0, 2, 0, 0, 2],
        [0, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 0, 2],
        [0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]

      expected_board = [
        [0, 0, 0, 0, 0, 4],
        [0, 0, 0, 0, 0, 2],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 4, 2],
        [0, 0, 0, 0, 0, 2],
        [0, 0, 0, 0, 0, 0]
      ]

      assert board |> Game.swipe(:right) == expected_board
    end

    test "swipe up" do
      board = [
        [0, 0, 2, 0, 0, 2],
        [0, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 0, 2],
        [0, 0, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]

      expected_board = [
        [0, 2, 2, 2, 0, 4],
        [0, 4, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]

      assert board |> Game.swipe(:up) == expected_board
    end

    test "swipe left" do
      board = [
        [0, 0, 2, 0, 0, 2],
        [0, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 0, 4],
        [0, 0, 0, 2, 0, 0],
        [8, 0, 0, 0, 8, 0]
      ]

      expected_board = [
        [4, 0, 0, 0, 0, 0],
        [2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [8, 0, 0, 0, 0, 0],
        [2, 0, 0, 0, 0, 0],
        [16, 0, 0, 0, 0, 0]
      ]

      assert board |> Game.swipe(:left) == expected_board
    end

    test "swipe down" do
      board = [
        [0, 0, 2, 0, 16, 2],
        [0, 2, 0, 0, 0, 0],
        [4, 2, 0, 0, 0, 0],
        [4, 0, 0, 0, 0, 4],
        [0, 0, 0, 2, 8, 0],
        [8, 2, 0, 0, 8, 0]
      ]

      expected_board = [
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [8, 2, 0, 0, 16, 2],
        [8, 4, 2, 2, 16, 4]
      ]

      assert board |> Game.swipe(:down) == expected_board
    end

    test "obstacle swipe" do
      board = [
        [0, 0, 2, 16, 16, 2],
        [0, 2, 1024, 0, -1, 1024],
        [0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 4, 2],
        [32, 0, -1, 2, 0, 64],
        [0, 0, 0, 0, 0, 0]
      ]

      expected_board = [
        [0, 0, 0, 2, 32, 2],
        [0, 0, 2, 1024, -1, 1024],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 8, 2],
        [0, 32, -1, 0, 2, 64],
        [0, 0, 0, 0, 0, 0]
      ]

      assert board |> Game.swipe(:right) == expected_board
    end
  end
end
