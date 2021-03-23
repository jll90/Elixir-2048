defmodule Engine2048.Game.Print do
  alias Engine2048.Game
  alias Engine2048.Board

  @type game_state() :: Game.game_state()
  @type board :: Board.t()

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

  @spec print_board(board()) :: :ok
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
    str = value |> Integer.to_string()
    len = str |> String.length()
    pad_empty(str, 4 - len)
  end

  @spec pad_empty(String.t(), integer()) :: String.t()
  defp pad_empty(s, 0), do: s

  defp pad_empty(s, count) do
    pad_empty(" #{s}", count - 1)
  end
end
