defmodule Engine2048.GameTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game
  alias Engine2048.Builder

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

  describe "Initialization" do
    test "can start a game" do
      assert {:ok, state} = Builder.new() |> Game.start()
    end

    test "game init state is set correctly" do
      start_value = 2
      new_value = 1
      obstacle_count = 3

      assert {:ok, state} =
               Builder.new()
               |> Builder.obstacle_count(obstacle_count)
               |> Builder.new_value(new_value)
               |> Builder.start_value(start_value)
               |> Game.start()

      assert Map.get(state, :turns) == 0
      refute Map.get(state, :noop)
      refute Map.get(state, :victory)
      assert Map.get(state, :curr)
      refute Map.get(state, :prev)
      assert Map.get(state, :score) == start_value
    end

    test "game starts with one filled tile" do
      {:ok, state} =
        Builder.new()
        |> Builder.obstacle_count(0)
        |> Game.start()

      assert Game.filled_tiles(state) == 1
    end
  end

  describe "Running turns" do
    test "can run a turn" do
      {:ok, init_state} = Builder.new() |> Builder.cols(3) |> Builder.rows(3) |> Game.start()

      assert init_state
    end

    test "game is lost when there are no empty tiles" do
      {:ok, init_state} = Builder.new() |> Builder.cols(3) |> Builder.rows(3) |> Game.start()

      board = [
        [1, 2, 4],
        [1, 2, 8],
        [1, 2, 0]
      ]

      fake_state =
        init_state
        |> Map.merge(%{
          curr: board
        })

      %{victory: victory} = fake_state |> Game.run_turn(:right)
      ## we do not refute because false means the game was lost
      assert victory == false
    end

    test "game is won when 2048 is reached" do
      {:ok, init_state} = Builder.new() |> Builder.cols(3) |> Builder.rows(3) |> Game.start()

      board = [
        [1, 2, 4],
        [1, 2, 8],
        [1, 1024, 1024]
      ]

      fake_state =
        init_state
        |> Map.merge(%{
          curr: board
        })

      %{victory: victory} = fake_state |> Game.run_turn(:right)
      ## we do not refute because false means the game was lost
      assert victory
    end
  end
end
