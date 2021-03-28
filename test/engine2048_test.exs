defmodule Engine2048Test do
  use ExUnit.Case
  doctest Engine2048

  describe "Initialization" do
    test "can quick start" do
      assert {:ok, _} = Engine2048.quick_start()
    end

    test "can start a game" do
    end
  end
end
