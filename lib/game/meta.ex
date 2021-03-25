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
    # |> IO.inspect(label: "tile_meta #{swipe_dir}")
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
            m
            |> Map.put(
              :deltax,
              {i |> IndexMapper.reverse_index(rows), j |> IndexMapper.reverse_index(rows)}
            )

          :down ->
            m |> Map.put(:deltay, {i, j})

          :up ->
            m
            |> Map.put(
              :deltay,
              {i |> IndexMapper.reverse_index(cols), j |> IndexMapper.reverse_index(cols)}
            )
        end

      m ->
        m
    end)

    # |> IO.inspect(label: "tile_meta #{swipe_dir}")
  end

  @spec calc_row_diff(GRow.t(), GRow.t()) :: [tile_meta()] | nil
  def calc_row_diff(r1, r2) do
    if r1 == r2 do
      []
    else
      if r1 |> GRow.shift() == r2 do
        GRow.calc_shift_diff(r1, r2)
      else
        calc_merge_diff(r1, r2)
      end
    end
  end

  @spec calc_merge_diff(GRow.t(), GRow.t()) :: [tile_meta()]
  def calc_merge_diff(r1, r2) do
    obstacle_count = r1 |> Enum.count(&(&1 == -1))

    if obstacle_count > 0 do
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
      shifted_row = r1 |> GRow.shift()
      shift_diff = GRow.calc_shift_diff(r1, shifted_row)

      reverse_shift_diff = shift_diff |> Enum.reverse()

      {meta, _} =
        r2
        |> Enum.with_index()
        |> Enum.filter(fn {x, _} ->
          x > 0
        end)
        |> Enum.reverse()
        |> Enum.map_reduce({reverse_shift_diff, 0}, fn {e, i}, {shift_acc, merge_count} ->
          shift_diff_find = fn i ->
            fn %{delta: {_, end_index}} ->
              end_index == i
            end
          end

          %{v: first_acc_val, delta: delta} = shift_acc |> List.first()
          # IO.inspect("#{e} - index: #{i}")
          # IO.inspect(shift_acc, label: "shift_acc")

          if e == first_acc_val do
            {start_index, _} = delta

            {%{v: e, i: i, delta: {start_index, i}}, {shift_acc |> Enum.drop(1), merge_count}}
          else
            %{v: tile1_v, delta: {tile1_start_index, _}} =
              shift_acc |> Enum.find(shift_diff_find.(i - merge_count))

            %{v: tile2_v, delta: {tile2_start_index, _}} =
              shift_acc |> Enum.find(shift_diff_find.(i - merge_count - 1))

            {[
               %{pv: tile1_v, delta: {tile1_start_index, i}, merge: true, i: i},
               %{pv: tile2_v, delta: {tile2_start_index, i}, merge: true, i: i},
               %{v: e, i: i, new: true}
             ], {shift_acc |> Enum.drop(2), merge_count + 1}}
          end
        end)

      meta |> List.flatten()
    end
  end

  @spec prepend_new([tile_meta()], non_neg_integer(), pos_integer()) :: [tile_meta()]
  def prepend_new(meta_list, i, value) do
    new_meta = %{new: value, i: i}
    [new_meta | meta_list]
  end
end
