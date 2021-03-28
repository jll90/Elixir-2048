defmodule Engine2048.Game do
  @moduledoc """
  Here the logic to start the game and to run turns is implemented
  """

  alias Engine2048.Board
  alias Engine2048.Game.{Meta, GRow}

  @type game_config :: %{
          cols: pos_integer(),
          max_value: pos_integer(),
          new_value: pos_integer(),
          obstacle_count: non_neg_integer(),
          rows: pos_integer(),
          start_value: pos_integer()
        }

  @type score() :: pos_integer()
  @type board() :: Board.t()
  @type swipe_dir() :: :up | :down | :left | :right

  @type noop() :: boolean() | nil
  @type victory() :: boolean() | nil

  @type game_state() :: %{
          config: game_config(),
          curr: board(),
          meta: [Meta.tile_meta()],
          noop: noop(),
          prev: board() | nil,
          score: score(),
          turns: non_neg_integer(),
          victory: victory()
        }

  @spec start(game_config()) :: {:ok, game_state()}
  def start(config) do
    %{
      cols: cols,
      rows: rows,
      new_value: _,
      start_value: start_value,
      obstacle_count: obstacle_count
    } = config

    random_index = Enum.random(0..(rows * cols))

    board =
      Board.new(rows, cols, 0)
      |> init_board(random_index, start_value, obstacle_count)

    meta = init_meta(random_index, start_value)

    game_state = %{
      config: config,
      curr: board,
      meta: meta,
      noop: nil,
      prev: nil,
      score: start_value,
      turns: 0,
      victory: nil
    }

    {:ok, game_state}
  end

  @spec init_board(Board.t(), non_neg_integer(), pos_integer(), pos_integer()) :: Board.t()
  defp init_board(board, init_index, start_value, obstacle_count) do
    board = board |> Board.replace_at(init_index, start_value)

    if obstacle_count > 0 do
      0..(obstacle_count - 1)
      |> Enum.to_list()
      |> Enum.reduce(board, fn _, b ->
        empty_tile_index =
          b
          |> Board.empty_tiles()
          |> Enum.random()

        board |> Board.replace_at(empty_tile_index, -1)
      end)
    else
      board
    end
  end

  @spec init_meta(pos_integer(), pos_integer()) :: [Meta.tile_meta()]
  defp init_meta(random_index, start_value) do
    [] |> Meta.prepend_new(random_index, start_value)
  end

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

  @spec run_turn(game_state(), swipe_dir()) :: game_state()
  def run_turn(game_state, swipe_dir) do
    do_run_turn(game_state, swipe_dir)
  end

  @spec score(game_state()) :: pos_integer()
  def score(%{score: score}), do: score

  @spec filled_tiles(game_state()) :: pos_integer()
  def filled_tiles(%{curr: board}), do: board |> Board.filled_tile_count()

  @spec do_run_turn(game_state(), swipe_dir()) :: game_state()
  defp do_run_turn(game_state, swipe_dir) do
    new_value = Kernel.get_in(game_state, [:config, :new_value])
    board = Map.get(game_state, :curr)
    swiped_board = board |> swipe(swipe_dir)

    if board == swiped_board do
      game_state |> Map.put(:noop, true)
    else
      random_tile_index =
        swiped_board
        |> Board.empty_tiles()
        |> Enum.random()

      board_with_piece = swiped_board |> Board.replace_at(random_tile_index, new_value)

      meta =
        Meta.calc_board_diff(board, swiped_board, swipe_dir)
        |> Meta.prepend_new(random_tile_index, new_value)

      victory = check_for_victory(board_with_piece, game_state |> Map.get(:config))

      game_state =
        game_state
        |> Map.put(:curr, board_with_piece)
        |> Map.put(:meta, meta)
        |> Map.put(:prev, board)
        |> Map.put(:turns, Map.get(game_state, :turns) + 1)
        |> Map.put(:victory, victory)
        |> Map.put(:noop, false)
        |> Map.put(:score, calc_score(game_state))

      game_state
    end
  end

  @doc false
  @spec calc_score(game_state()) :: pos_integer()
  defp calc_score(%{curr: board}), do: board |> Board.max()

  @doc false
  @spec check_for_victory(Board.t(), game_config()) :: victory()
  defp check_for_victory(board, config) do
    cond do
      board
      |> List.flatten()
      |> Enum.any?(fn v -> v == Map.get(config, :max_value) end) ->
        true

      board |> Board.full?() ->
        false

      true ->
        nil
    end
  end
end
