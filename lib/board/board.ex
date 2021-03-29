defmodule Engine2048.Board do
  @moduledoc false
  alias Engine2048.{Board, Tile}
  alias Engine2048.Utils.IndexMapper

  @type t :: [[Tile.t()]]

  @spec new(
          non_neg_integer(),
          non_neg_integer(),
          non_neg_integer() | (non_neg_integer() -> integer())
        ) :: Board.t()

  def new(rows, cols, index_value_mapper) when is_function(index_value_mapper) do
    List.duplicate(0, rows * cols)
    |> Enum.with_index()
    |> Enum.map(fn {_, i} ->
      index_value_mapper.(i)
    end)
    |> Enum.chunk_every(cols)
  end

  def new(rows, cols, init_value \\ 0) do
    List.duplicate(init_value, rows * cols)
    |> Enum.chunk_every(cols)
  end

  @spec replace_at(Board.t(), non_neg_integer(), integer()) :: Board.t()
  def replace_at(board, i, val) do
    rows = board |> Board.rows()

    board
    |> List.flatten()
    |> List.replace_at(i, val)
    |> Enum.chunk_every(rows)
  end

  @spec clear_at(Board.t(), non_neg_integer()) :: Board.t()
  def clear_at(board, i) do
    board
    |> Board.replace_at(i, 0)
  end

  @spec rows(Board.t()) :: pos_integer()
  def rows(board) do
    board |> length()
  end

  @spec cols(Board.t()) :: pos_integer()
  def cols(board) do
    board |> Enum.map(& &1) |> List.first() |> length()
  end

  @spec tile_count(Board.t()) :: pos_integer()
  def tile_count(board) do
    board |> List.flatten() |> length()
  end

  @spec filled_tile_count(Board.t()) :: non_neg_integer()
  def filled_tile_count(board) do
    board |> List.flatten() |> Enum.count(&(&1 != 0))
  end

  @spec empty_tile_count(Board.t()) :: non_neg_integer()
  def empty_tile_count(board) do
    board |> List.flatten() |> Enum.count(&(&1 == 0))
  end

  @spec obstacle_count(Board.t()) :: non_neg_integer()
  def obstacle_count(board) do
    board |> List.flatten() |> Enum.count(&(&1 == -1))
  end

  @spec empty_tiles(Board.t()) :: [non_neg_integer()]
  def empty_tiles(board) do
    board
    |> List.flatten()
    |> Enum.with_index()
    |> Enum.filter(fn {v, _} -> v == 0 end)
    |> Enum.map(fn {_, i} -> i end)
  end

  @spec rotate_right(Board.t()) :: Board.t()
  def rotate_right(board) do
    rows = board |> Board.rows()
    cols = board |> Board.cols()

    board
    |> List.flatten()
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      {v, i, i |> IndexMapper.rotate_index_map(rows, cols, 90)}
    end)
    |> Enum.map(fn {_, _, j} ->
      board |> List.flatten() |> Enum.at(j)
    end)
    |> Enum.chunk_every(rows)
  end

  @spec rotate_left(Board.t()) :: Board.t()
  def rotate_left(board) do
    board
    |> Board.rotate_right()
    |> Board.rotate_right()
    |> Board.rotate_right()
  end

  @spec rotate_180(Board.t()) :: Board.t()
  def rotate_180(board) do
    board
    |> Board.rotate_right()
    |> Board.rotate_right()
  end

  @spec full?(Board.t()) :: boolean()
  def full?(board) do
    board |> List.flatten() |> Enum.all?(&(&1 != 0))
  end

  @spec empty?(Board.t()) :: boolean()
  def empty?(board) do
    board |> List.flatten() |> Enum.all?(&(&1 == 0))
  end

  @spec max(Board.t()) :: pos_integer()
  def max(board) do
    board |> List.flatten() |> Enum.max()
  end
end
