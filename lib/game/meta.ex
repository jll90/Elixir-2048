defmodule Engine2048.Game.Meta do
  alias Engine2048.Board
  alias Engine2048.Game.GRow
  alias Engine2048.Utils.IndexMapper

  @type board() :: GRow.board()
  @type swipe_dir() :: GRow.swipe_dir()
  @type tile_meta :: %{
          optional(:new) => boolean(),
          optional(:merged) => boolean(),
          optional(:delta) => {non_neg_integer(), non_neg_integer()},
          optional(:deltax) => {non_neg_integer(), non_neg_integer()},
          optional(:deltay) => {non_neg_integer(), non_neg_integer()},
          optional(:pv) => integer(),
          v: integer(),
          i: non_neg_integer()
        }

  @spec swipe_dir_to_degs(swipe_dir()) :: IndexMapper.rotate_degs()
  def swipe_dir_to_degs(:right), do: 0
  def swipe_dir_to_degs(:down), do: 270
  def swipe_dir_to_degs(:left), do: 180
  def swipe_dir_to_degs(:up), do: 90

  @spec calc_board_diff(Board.t(), Board.t(), swipe_dir()) :: [tile_meta()]
  def calc_board_diff(b1, b2, :right) do
    do_calc_board_diff(b1, b2) |> map_meta_indeces(b1, :right)
  end

  def calc_board_diff(b1, b2, :up) do
    b1 = b1 |> Board.rotate_right()
    b2 = b2 |> Board.rotate_right()

    do_calc_board_diff(b1, b2) |> map_meta_indeces(b1, :up)
  end

  def calc_board_diff(b1, b2, :left) do
    b1 = b1 |> Board.rotate_180()
    b2 = b2 |> Board.rotate_180()

    do_calc_board_diff(b1, b2) |> map_meta_indeces(b1, :left)
  end

  def calc_board_diff(b1, b2, :down) do
    b1 = b1 |> Board.rotate_left()
    b2 = b2 |> Board.rotate_left()

    do_calc_board_diff(b1, b2) |> map_meta_indeces(b1, :down)
  end

  @spec do_calc_board_diff(Board.t(), Board.t()) :: [tile_meta()]
  defp do_calc_board_diff(b1, b2) do
    Enum.zip(b1, b2)
    |> Enum.map(fn {r1, r2} ->
      calc_row_diff(r1, r2)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {r, row_i} ->
      r
      |> Enum.map(fn %{i: i} = meta ->
        shifted_i = i |> IndexMapper.flatten_index(row_i, Board.cols(b1))
        meta |> Map.merge(%{i: shifted_i})
      end)
    end)
  end

  @spec map_meta_indeces([[tile_meta()]], Board.t(), swipe_dir()) :: [tile_meta()]
  def map_meta_indeces(meta_list, board, swipe_dir) do
    rows = board |> Board.rows()
    cols = board |> Board.cols()

    meta_list
    |> List.flatten()
    |> IO.inspect(label: "tile_meta #{swipe_dir}")
    |> Enum.map(fn %{i: i} = meta ->
      degs = swipe_dir |> swipe_dir_to_degs()

      shifted_i =
        i
        |> IndexMapper.rotate_index_map(rows, cols, degs)

      meta |> Map.merge(%{i: shifted_i})
    end)
    |> Enum.map(fn
      %{delta: {i, j}} = m ->
        case swipe_dir do
          :right ->
            m |> Map.put(:deltax, {i, j})

          :left ->
            m |> Map.put(:deltax, {i |> reverse_index(rows), j |> reverse_index(rows)})

          :down ->
            m |> Map.put(:deltay, {i, j})

          :up ->
            m |> Map.put(:deltay, {i |> reverse_index(cols), j |> reverse_index(cols)})
        end

      m ->
        m
    end)
    |> IO.inspect(label: "tile_meta #{swipe_dir}")
  end

  @spec calc_row_diff(GRow.t(), GRow.t()) :: [tile_meta()] | nil
  def calc_row_diff(r1, r2) do
    if r1 == r2 do
      []
    else
      if r1 |> GRow.shift() == r2 do
        r1_values = r1 |> Enum.with_index() |> Enum.filter(fn {v, _} -> v > 0 end)
        r2_values = r2 |> Enum.with_index() |> Enum.filter(fn {v, _} -> v > 0 end)

        Enum.zip(r1_values, r2_values)
        |> Enum.map(fn {{_, i}, {v, j}} -> %{v: v, i: j, delta: {i, j}} end)
      else
        calc_merge_diff(r1, r2)
      end
    end
  end

  @spec calc_merge_diff(GRow.t(), GRow.t()) :: [tile_meta()]
  def calc_merge_diff(r1, r2) do
    obstacles = r1 |> Enum.filter(&(&1 == -1))

    if obstacles |> length() > 0 do
      # for now
      split_r1 = r1 |> Enum.with_index() |> Enum.chunk_by(fn {v, _} -> v == -1 end)
      split_r2 = r2 |> Enum.with_index() |> Enum.chunk_by(fn {v, _} -> v == -1 end)

      # IO.inspect(split_r1)
      # IO.inspect(split_r2)

      result =
        Enum.zip(split_r1, split_r2)
        |> Enum.map(fn {r1, r2} ->
          clean_r1 = r1 |> Enum.map(fn {v, _} -> v end)
          clean_r2 = r2 |> Enum.map(fn {v, _} -> v end)
          {_, start_index} = r1 |> List.first()

          calc_row_diff(clean_r1, clean_r2)
          |> Enum.map(fn
            %{delta: {i, j}, i: k} = meta ->
              meta
              |> Map.merge(%{delta: {i + start_index, j + start_index}, i: k + start_index})

            %{i: i} = meta ->
              meta
              |> Map.merge(%{i: i + start_index})
          end)
        end)

      result
      |> List.flatten()
      |> Enum.filter(&(!is_nil(&1)))
    else
      merged_r1 = r1 |> GRow.shift() |> GRow.merge()
      ## the merge operation will generate a zero towards the end of the row
      ## this zero marks the boundary between numbers 
      ## that were shifted in front of the merge and behind the merge 
      ## we take in front of the merge to mean left of the merge
      ## and behind the merge right of the merge
      reverse_zero_boundary_index =
        merged_r1
        ## row is reversed because there are no zeroes towards the right
        ## meaning that the first zero is indeed the boundary - and not a leftmost empty tile
        |> Enum.reverse()
        |> Enum.take_while(&(&1 != 0))
        |> length()

      zero_boundary_index = reverse_zero_boundary_index |> reverse_index(r1 |> length())

      indexed_r2 =
        r2
        |> Enum.with_index()
        |> Enum.take(zero_boundary_index + 1)
        |> Enum.filter(fn {v, _} -> v > 0 end)

      left_of_boundary_non_zeroes = indexed_r2 |> length()

      left_of_boundary_meta =
        if left_of_boundary_non_zeroes > 0 do
          indexed_r1 =
            r1
            |> Enum.with_index()
            |> Enum.filter(fn {v, _} -> v > 0 end)
            |> Enum.take(left_of_boundary_non_zeroes)

          Enum.zip(indexed_r1, indexed_r2)
          |> Enum.map(fn {{_, i}, {v, j}} -> %{v: v, i: j, delta: {i, j}} end)
        else
          []
        end

      reverse_indexed_r2 =
        r2
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.take(reverse_zero_boundary_index - 1)

      right_of_boundary_non_zeroes = reverse_indexed_r2 |> length()

      reverse_indexed_r1 =
        r1
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.filter(fn {v, _} -> v > 0 end)
        |> Enum.take(right_of_boundary_non_zeroes)

      right_of_boundary_meta =
        Enum.zip(reverse_indexed_r1, reverse_indexed_r2)
        |> Enum.map(fn {{_, i}, {v, j}} ->
          %{
            v: v,
            i: j |> reverse_index(r1 |> length()),
            delta: {i |> reverse_index(r1 |> length), j |> reverse_index(r1 |> length())}
          }
        end)

      reverse_shifted_r1 = r1 |> GRow.shift() |> Enum.reverse()

      merge_values =
        reverse_shifted_r1
        |> Enum.with_index()
        |> Enum.find_value(fn {_, i} ->
          n = reverse_shifted_r1 |> Enum.at(i)
          m = reverse_shifted_r1 |> Enum.at(i + 1)
          if GRow.can_merge?(n, m), do: [n, m], else: nil
        end)

      merge_indeces =
        find_to_merge_indeces(r1, merge_values |> List.first(), merge_values |> List.last())

      []
      |> Enum.concat(left_of_boundary_meta)
      |> Enum.concat(right_of_boundary_meta)
      |> Enum.concat([
        %{
          merge: true,
          i: zero_boundary_index + 1,
          pv: Enum.at(r1 |> GRow.shift(), zero_boundary_index),
          delta: {merge_indeces |> List.first(), zero_boundary_index + 1}
        },
        %{
          merge: true,
          i: zero_boundary_index + 1,
          pv: Enum.at(r1 |> GRow.shift(), zero_boundary_index + 1),
          delta: {merge_indeces |> List.last(), zero_boundary_index + 1}
        }
      ])
      |> Enum.concat([
        %{new: true, i: zero_boundary_index + 1}
      ])
    end
  end

  defp find_to_merge_indeces(r1, v1, v2) do
    reversed_r1 = r1 |> Enum.reverse()

    i =
      reversed_r1
      |> Enum.find_index(fn v ->
        v == v1
      end)

    j =
      reversed_r1
      |> Enum.with_index()
      |> Enum.find_index(fn {v, j} ->
        v == v2 && j > i
      end)

    [i, j] |> Enum.map(&reverse_index(&1, r1 |> length())) |> Enum.reverse()
  end

  @spec reverse_index(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp reverse_index(i, length) when i <= length do
    length - 1 - i
  end

  @spec prepend_new([tile_meta()], non_neg_integer(), pos_integer()) :: [tile_meta()]
  def prepend_new(meta_list, i, value) do
    new_meta = %{new: value, i: i}
    [new_meta | meta_list]
  end
end
