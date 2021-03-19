defmodule Engine2048.Game do
  alias Engine2048.Board
  alias Engine2048.Game.GRow

  @type board() :: Board.t()
  @type swipe_dir() :: :up | :down | :left | :right

  @spec swipe(board(), swipe_dir()) :: board()
  def swipe(board, :right) do
    board
    |> Enum.map(&GRow.swipe(&1))
  end

  def swipe(board, :up) do
    board
    |> Board.rotate_right()
    |> swipe(:right)
    |> Board.rotate_left()
  end

  def swipe(board, :left) do
    board
    |> Board.rotate_180()
    |> swipe(:right)
    |> Board.rotate_180()
  end

  def swipe(board, :down) do
    board
    |> Board.rotate_left()
    |> swipe(:right)
    |> Board.rotate_right()
  end
end
