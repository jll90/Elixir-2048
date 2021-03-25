defmodule Engine2048.Game.GRowTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game.GRow

  describe "GRow swipes" do
    test "swipes are merged toward the wall" do
      assert [0, 0, 0, 2, 2, 2] |> GRow.swipe() == [0, 0, 0, 0, 2, 4]
      assert [0, 0, 2, 2, 2, 0] |> GRow.swipe() == [0, 0, 0, 0, 2, 4]
    end

    test "there can be multiple merges in a row" do
      assert [0, 0, 2, 2, 8, 8] |> GRow.swipe() == [0, 0, 0, 0, 4, 16]
      assert [4, 4, 4, 4, 8, 8] |> GRow.swipe() == [0, 0, 0, 8, 8, 16]
      assert [0, 0, 2, 2, 2, 0] |> GRow.swipe() == [0, 0, 0, 0, 2, 4]
      assert [0, 0, 2, 2, 2, 4, 4, 4] |> GRow.swipe() == [0, 0, 0, 0, 2, 4, 4, 8]
    end

    test "obstacle swipes" do
      assert [0, 0, 0, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 2, -1, 2]
      assert [0, 0, 2, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 4, -1, 2]
      assert [0, 0, 2, 2, -1, -1] |> GRow.swipe() == [0, 0, 0, 4, -1, -1]
      assert [0, 2, 2, -1, 2, 2] |> GRow.swipe() == [0, 0, 4, -1, 0, 4]
      assert [2, 2, -1, -1, 2, 2] |> GRow.swipe() == [0, 4, -1, -1, 0, 4]
      assert [4, 4, 2, 2, -1, -1, 2, 2] |> GRow.swipe() == [0, 0, 8, 4, -1, -1, 0, 4]
    end

    test "other test cases" do
      assert [2, 0, 4, 0, 8, 8, 0, 32, 0] |> GRow.swipe() == [0, 0, 0, 0, 0, 2, 4, 16, 32]
    end
  end

  describe "GRow diff" do
    test "shift_diff works" do
      result = GRow.calc_shift_diff([0, 1, 0, 4], [0, 0, 1, 4])

      assert result == [
               %{v: 1, i: 2, delta: {1, 2}},
               %{v: 4, i: 3, delta: {3, 3}}
             ]
    end

    test "find merges works" do
      ## row has already been merged and filled w/ zeroes
      # result = [0, 4, 4, 8, 8, 0, 16, 32] |> GRow.find_merges()

      # assert result == [
      #          {[0, 4], 1, 2},
      #          {[0, 8], 3, 4},
      #          {[0, 16], 5, 6}
      #        ]
    end

    test "find non_merges works" do
      ## row has already been merged and filled w/ zeroes
      # result = [0, 0, 4, 0, 8, 0, 16, 8, 4] |> GRow.find_non_merges()
      # assert result == [{4, 8}, {8, 7}]
    end
  end
end
