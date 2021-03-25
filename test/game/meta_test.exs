defmodule Engine2048.Game.MetaTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game.Meta

  describe "GRow swipes diff" do
    test "full row meta is []" do
      r1 = [2, 4, 8, 1, 2, 4]
      r2 = r1

      result = Meta.calc_row_diff(r1, r2)
      assert result == []
    end

    test "can calculate meta for rows containing zeroes and no merges" do
      r1 = [1, 0, 4, 0, 1, 0, 4]
      r2 = [0, 0, 0, 1, 4, 1, 4]

      result = Meta.calc_row_diff(r1, r2)
      assert is_list(result)
      assert result |> find_delta(3, 0, 3)
      assert result |> find_delta(4, 2, 4)
      assert result |> find_delta(5, 4, 5)
      assert result |> find_delta(6, 6, 6)
    end

    test "can calculate meta for single merges" do
      r1 = [2, 0, 4, 0, 8, 0, 8, 0, 32, 0]
      r2 = [0, 0, 0, 0, 0, 0, 2, 4, 16, 32]

      result = Meta.calc_row_diff(r1, r2)
      assert is_list(result)
      assert result |> find_delta(6, 0, 6)
      assert result |> find_delta(7, 2, 7)
      assert result |> find_delta(9, 8, 9)
      assert result |> find_new(8)

      assert result |> find_delta(8, 4, 8, true)
      assert result |> find_delta(8, 6, 8, true)
    end

    test "can calculate meta for multiple merges" do
      r1 = [2, 0, 4, 0, 8, 0, 8, 16, 32, 32]
      r2 = [0, 0, 0, 0, 0, 2, 4, 16, 16, 64]

      result = Meta.calc_row_diff(r1, r2)
      assert is_list(result)
      assert result |> find_new(7)
      assert result |> find_new(9)

      assert result |> find_delta(7, 4, 7, true)
      assert result |> find_delta(7, 6, 7, true)
      assert result |> find_delta(9, 8, 9, true)
      assert result |> find_delta(9, 9, 9, true)

      assert result |> find_delta(5, 0, 5)
      assert result |> find_delta(6, 2, 6)
    end

    test "can calculate meta for merges w/ obstacles" do
      r1 = [2, 0, 4, -1, 8, 8, -1, 32, 0]
      r2 = [0, 2, 4, -1, 0, 16, -1, 0, 32]

      result = Meta.calc_row_diff(r1, r2)
      assert is_list(result)

      assert result |> find_delta(1, 0, 1)
      assert result |> find_delta(2, 2, 2)
      assert result |> find_delta(8, 7, 8)
      assert result |> find_new(5)

      assert result |> find_delta(5, 4, 5, true)
      assert result |> find_delta(5, 5, 5, true)
    end

    test "can generate meta for right swipes" do
      b1 = [
        [1, 2, 0],
        [2, 0, 4],
        [8, 4, 0]
      ]

      b2 = [
        [0, 1, 2],
        [0, 2, 4],
        [0, 8, 4]
      ]

      result = Meta.calc_board_diff(b1, b2, :right)
      assert is_list(result)

      assert result |> find_delta(1, 0, 1)
      assert result |> find_delta(2, 1, 2)
      assert result |> find_delta(4, 0, 1)
      assert result |> find_delta(5, 2, 2)
      assert result |> find_delta(7, 0, 1)
      assert result |> find_delta(8, 1, 2)
    end

    test "can generate meta for left swipes" do
      b1 = [
        [1, 2, 0],
        [2, 0, 4],
        [8, 4, 0]
      ]

      b2 = [
        [1, 2, 0],
        [2, 4, 0],
        [8, 4, 0]
      ]

      result = Meta.calc_board_diff(b1, b2, :left)
      assert is_list(result)

      assert result |> find_delta(4, 0, 1)
    end

    test "can generate meta for down swipes" do
      b1 = [
        [1, 2, 0],
        [2, 0, 4],
        [8, 4, 0]
      ]

      b2 = [
        [1, 0, 0],
        [2, 2, 0],
        [8, 4, 4]
      ]

      result = Meta.calc_board_diff(b1, b2, :down)
      assert is_list(result)

      assert result |> find_delta(4, 0, 1)
      assert result |> find_delta(7, 2, 2)
      assert result |> find_delta(8, 1, 2)
    end

    test "can generate meta up swipes" do
      b1 = [
        [1, 2, 0],
        [2, 0, 4],
        [8, 4, 0]
      ]

      b2 = [
        [1, 2, 4],
        [2, 4, 0],
        [8, 0, 0]
      ]

      result = Meta.calc_board_diff(b1, b2, :up)
      assert is_list(result)

      assert result |> find_delta(2, 1, 2)
      assert result |> find_delta(4, 0, 1)
    end

    def find_new(meta_list, j) do
      meta_list
      |> Enum.find(fn e ->
        Map.get(e, :new) && Map.get(e, :i) == j
      end)
    end

    def find_delta(meta_list, j, test_start, test_finish, with_merge \\ false) do
      meta_list
      |> Enum.find(fn
        %{i: i, delta: {start, finish}} = e ->
          delta_test = i == j && start == test_start && finish == test_finish

          if with_merge do
            delta_test && Map.get(e, :merge)
          else
            delta_test
          end

        _ ->
          false
      end)
    end
  end
end
