defmodule Engine2048.Game.GRowTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Game.GRow

  describe "GRow swipes" do
    test "swipes are merged toward the wall" do
      assert [0, 0, 0, 2, 2, 2] |> GRow.swipe() == [0, 0, 0, 0, 2, 4]
    end

    test "obstacle swipes" do
      assert [0, 0, 0, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 2, -1, 2]
      assert [0, 0, 2, 2, -1, 2] |> GRow.swipe() == [0, 0, 0, 4, -1, 2]
      assert [0, 0, 2, 2, -1, -1] |> GRow.swipe() == [0, 0, 0, 4, -1, -1]
      assert [0, 2, 2, -1, 2, 2] |> GRow.swipe() == [0, 2, 2, -1, 0, 4]
      assert [2, 2, -1, -1, 2, 2] |> GRow.swipe() == [2, 2, -1, -1, 0, 4]
    end
  end
end
