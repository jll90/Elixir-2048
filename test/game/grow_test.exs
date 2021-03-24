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
      # assert [0, 0, 2, 2, 2, 0] |> GRow.swipe() == [0, 0, 0, 0, 2, 4]
    end

    test "obstacle swipes" do
      assert [0, 0, 0, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 2, -1, 2]
      assert [0, 0, 2, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 4, -1, 2]
      assert [0, 0, 2, 2, -1, -1] |> GRow.swipe() == [0, 0, 0, 4, -1, -1]
      assert [0, 2, 2, -1, 2, 2] |> GRow.swipe() == [0, 0, 4, -1, 0, 4]
      assert [2, 2, -1, -1, 2, 2] |> GRow.swipe() == [0, 4, -1, -1, 0, 4]
    end

    test "other test cases" do
      assert [2, 0, 4, 0, 8, 8, 0, 32, 0] |> GRow.swipe() == [0, 0, 0, 0, 0, 2, 4, 16, 32]
    end
  end
end
