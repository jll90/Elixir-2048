defmodule Engine2048.BoardTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Board

  describe "Board generation" do
    test "can generate n*m board w/ initial values" do
      board = Board.new(2, 3, 1)
      rows = board |> Enum.map(& &1)
      cols = rows |> List.first()

      assert board |> length() == 2
      assert cols |> length() == 3
      assert board |> List.flatten() |> length() == 6
      assert board |> List.flatten() |> Enum.all?(&(&1 == 1))
    end
  end

  describe "Board info" do
    test "can get rows count" do
      board = Board.new(2, 4)
      assert 2 == board |> Board.rows()
    end

    test "can get column count" do
      board = Board.new(2, 4)
      assert 4 == board |> Board.cols()
    end

    test "can get tile count" do
      board = Board.new(2, 4)
      assert 8 == board |> Board.tile_count()
    end
  end

  describe "Board rotation" do
    test "can rotate boards 90 degrees to the right" do
      board = Board.new(3, 3, &(&1 + 1))

      expected_board = [
        [7, 4, 1],
        [8, 5, 2],
        [9, 6, 3]
      ]

      assert board |> Board.rotate_right() == expected_board
    end

    test "can rotate board 90 degrees to the left" do
      board = Board.new(3, 3, &(&1 + 1))

      expected_board = [
        [3, 6, 9],
        [2, 5, 8],
        [1, 4, 7]
      ]

      assert board |> Board.rotate_left() == expected_board
    end

    test "can rotate boards 180 degrees" do
      board = Board.new(3, 3, &(&1 + 1))

      expected_board = [
        [9, 8, 7],
        [6, 5, 4],
        [3, 2, 1]
      ]

      assert board |> Board.rotate_180() == expected_board
      assert board |> Board.rotate_180() |> Board.rotate_180() == board
    end

    test "can rotate right non-squared boards (special case)" do
      board = Board.new(2, 3, &(&1 + 1))
      # [1, 2, 3] 
      # [4, 5, 6]

      expected_board = [
        [4, 1],
        [5, 2],
        [6, 3]
      ]

      assert board |> Board.rotate_right() == expected_board
    end
  end

  describe "Board state" do
    test "can check whether empty" do
      board = Board.new(2, 2, 0)
      assert board |> Board.empty?()
    end

    test "can check whether full" do
      board = Board.new(2, 2, 1)
      assert board |> Board.full?()
    end
  end
end
