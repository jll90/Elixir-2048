defmodule Engine2048.Game do
  alias Engine2048.Board
  alias Engine2048.Game.{Meta, GRow}

  @type game_config :: %{
          cols: pos_integer(),
          max_value: pos_integer(),
          new_value: pos_integer(),
          obstacle_count: non_neg_integer(),
          rows: pos_integer()
        }

  @type board() :: Board.t()
  @type swipe_dir() :: :up | :down | :left | :right
  @type victory() :: boolean() | nil
  @type game_state() :: %{
          config: game_config(),
          curr: board(),
          meta: [Meta.tile_meta()],
          prev: board() | nil,
          turns: pos_integer(),
          victory: victory()
        }

  @spec start(game_config()) :: {:ok, game_state()}
  def start(config) do
    %{
      cols: cols,
      rows: rows,
      new_value: new_value,
      obstacle_count: obstacle_count
    } = config

    random_index = Enum.random(0..(rows * cols))
    board = Board.new(rows, cols, 0) |> Board.replace_at(random_index, new_value)

    board =
      if obstacle_count > 0 do
        0..(obstacle_count - 1)
        |> Enum.map(& &1)
        |> Enum.reduce(board, fn _, b ->
          empty_tile_index =
            b
            |> Board.empty_tiles()
            |> Enum.random()

          b |> Board.replace_at(empty_tile_index, -1)
        end)
      end

    game_state = %{
      config: config,
      curr: board,
      meta: [] |> Meta.prepend_new(random_index, new_value),
      prev: nil,
      turns: 0,
      victory: nil
    }

    game_state |> print()

    {:ok, game_state}
  end

  @spec quick_start() :: {:ok, game_state()}
  def quick_start() do
    %{
      cols: 4,
      rows: 4,
      new_value: 1,
      obstacle_count: 1,
      max_value: 2048
    }
    |> start()
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

  @spec run_turn(game_state(), swipe_dir()) :: {:ok, game_state()}
  def run_turn(game_state, swipe_dir) do
    {:ok, do_run_turn(game_state, swipe_dir)}
  end

  def run_turn!(game_state, swipe_dir) do
    do_run_turn(game_state, swipe_dir)
  end

  defp do_run_turn(game_state, swipe_dir) do
    new_value = Kernel.get_in(game_state, [:config, :new_value])
    board = Map.get(game_state, :curr)
    swiped_board = board |> swipe(swipe_dir)

    if board == swiped_board do
      game_state |> print()

      game_state
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

      game_state |> print()

      game_state
    end
  end

  @spec check_for_victory(Board.t(), game_config()) :: victory()
  def check_for_victory(board, config) do
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

  @spec print(game_state()) :: :ok
  def print(game_state) do
    %{
      turns: turns,
      victory: victory,
      curr: board,
      prev: prev_board
    } = game_state

    IO.puts("==================================")
    IO.puts("Victory: #{victory}")
    IO.puts("Turns: #{turns}")
    IO.puts("\n")

    if prev_board, do: prev_board |> print_board()
    IO.puts("\n")
    IO.puts("\n")
    board |> print_board()
    IO.puts("\n")

    :ok
  end

  @spec print_board(Board.t()) :: :ok
  defp print_board(board) do
    board
    |> Enum.each(fn r ->
      str_row =
        r
        |> Enum.map(fn v ->
          format_value(v)
        end)
        |> Enum.join("|")

      IO.puts(str_row)
      IO.puts("------------------------------------")
    end)

    :ok
  end

  @spec format_value(integer()) :: String.t()
  defp format_value(value) do
    len = value |> Integer.to_string() |> String.length()
    pad_empty(value, 4 - len)
  end

  @spec pad_empty(String.t(), non_neg_integer()) :: String.t()
  defp pad_empty(s, 0), do: s

  defp pad_empty(s, count) do
    pad_empty(" #{s}", count - 1)
  end
end
