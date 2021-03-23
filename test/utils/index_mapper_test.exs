defmodule Engine2048.Utils.IndexMapperTest do
  use ExUnit.Case, async: true
  doctest Engine2048

  alias Engine2048.Utils.IndexMapper

  describe "IndexMapper on Rotation" do
    test "it works" do
      l1 = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8]
      ]

      assert [2, 5, 8, 1, 4, 7, 0, 3, 6] |> Enum.reverse() ==
               l1 |> List.flatten() |> Enum.map(&IndexMapper.rotate_index_map(&1, 3, 3, 90))

      assert [2, 5, 8, 1, 4, 7, 0, 3, 6] ==
               l1 |> List.flatten() |> Enum.map(&IndexMapper.rotate_index_map(&1, 3, 3, 270))

      assert l1 |> List.flatten() |> Enum.reverse() ==
               l1 |> List.flatten() |> Enum.map(&IndexMapper.rotate_index_map(&1, 3, 3, 180))
    end
  end

  describe "IndexMapper on row shifting" do
    test "it works" do
      l1 = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8]
      ]

      flat_l1 = l1 |> List.flatten()
      ## we grab number 4 sitting @ at the 1 - first row
      assert 1 |> IndexMapper.flatten_index(1, 3) == flat_l1 |> Enum.find_index(&(&1 == 4))
    end
  end
end
