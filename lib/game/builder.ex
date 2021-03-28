defmodule Engine2048.Builder do
  @moduledoc """
  This module includes functions to build a game
  with different configurations.\n

  All of the functions in this module can be chained to obtain a configuration of one's choosing, save the `new` function.

  ## Examples
      iex> Builder.new() |> Builder.cols(3) |> Builder.rows(3)
      "Outputs configuration"
  """

  ## this is begging for a macro
  alias Engine2048.Game

  @type config :: Game.game_config()

  @default_config %{
    cols: 6,
    max_value: 2048,
    new_value: 1,
    obstacle_count: 0,
    rows: 6,
    start_value: 2
  }

  @doc """
    It outputs the default configuration.

  ## Examples
    iex> Builder.new()
  """
  @spec new() :: config()
  def new(), do: @default_config

  @doc """
    Sets the number of columns on the board.
  """
  @spec cols(config(), pos_integer()) :: config()
  def cols(config, cols) do
    config |> Map.put(:cols, cols)
  end

  @doc """
    Sets the number of rows on the board.
  """
  @spec rows(config(), pos_integer()) :: config()
  def rows(config, rows) do
    config |> Map.put(:rows, rows)
  end

  @doc """
    Sets the value of the tile that spawns after each iteration.
  """
  @spec new_value(config(), pos_integer()) :: config()
  def new_value(config, new_value) do
    config |> Map.put(:new_value, new_value)
  end

  @doc """
    Sets the value of the first tile on the board upon initialization.
  """
  @spec start_value(config(), pos_integer()) :: config()
  def start_value(config, start_value) do
    config |> Map.put(:start_value, start_value)
  end

  @doc """
    Sets the obstacle count, i.e. obstacles on the board for added fun and increased difficulty.
  """
  @spec obstacle_count(config(), pos_integer()) :: config()
  def obstacle_count(config, count) do
    config |> Map.put(:obstacle_count, count)
  end
end
