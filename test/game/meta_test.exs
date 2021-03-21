defmodule Engine2048.Game.MetaTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game.Meta

  describe "GRow swipes diff" do
    test "full row meta is nil" do
      r1 = [2, 4, 8, 1, 2, 4]
      r2 = r1

      result = Meta.calc_row_diff(r1, r2)
      refute result
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

    test "can calculate meta for merges" do
      r1 = [2, 0, 4, 0, 8, 8, 0, 32, 0]
      r2 = [0, 0, 0, 0, 0, 2, 4, 16, 32]

      result = Meta.calc_row_diff(r1, r2)
      assert result
    end

    def find_delta(meta_list, j, test_start, test_finish) do
      meta_list
      |> Enum.find(fn %{i: i, delta: {start, finish}} ->
        i == j && start == test_start && finish == test_finish
      end)
    end
  end
end
