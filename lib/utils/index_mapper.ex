defmodule Engine2048.Utils.IndexMapper do
  @type rotation_degs :: 0 | 90 | 180 | 270
  @spec right_rotate_index_map(non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  def right_rotate_index_map(i, rows, cols) do
    cols * (rows - 1 - rem(i, rows)) + div(i, rows)
  end

  @spec rotate_index_map(non_neg_integer(), non_neg_integer(), non_neg_integer(), rotation_degs()) ::
          non_neg_integer()
  def rotate_index_map(i, _, _, 0), do: i

  def rotate_index_map(i, rows, cols, 90) do
    i |> right_rotate_index_map(rows, cols)
  end

  def rotate_index_map(i, rows, cols, 270) do
    i
    |> right_rotate_index_map(rows, cols)
    |> right_rotate_index_map(rows, cols)
    |> right_rotate_index_map(rows, cols)
  end

  def rotate_index_map(i, rows, cols, 180) do
    i
    |> right_rotate_index_map(rows, cols)
    |> right_rotate_index_map(rows, cols)
  end

  @spec flatten_index(non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  def flatten_index(i, nth_row, cols) do
    i + nth_row * cols
  end

  @spec reverse_index(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def reverse_index(i, length) when i <= length do
    length - 1 - i
  end
end
