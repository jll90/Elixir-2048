defmodule Engine2048.Builder do
  @moduledoc """
  This module includes functions to build a game
  with different configurations
  """
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

  ## this is screamint for a macro
  #
  @spec new() :: config()
  def new(), do: @default_config

  @spec cols(config(), pos_integer()) :: config()
  def cols(config, cols) do
    config |> Map.put(:cols, cols)
  end

  @spec rows(config(), pos_integer()) :: config()
  def rows(config, rows) do
    config |> Map.put(:rows, rows)
  end

  @spec new_value(config(), pos_integer()) :: config()
  def new_value(config, new_value) do
    config |> Map.put(:new_value, new_value)
  end

  @spec start_value(config(), pos_integer()) :: config()
  def start_value(config, start_value) do
    config |> Map.put(:start_value, start_value)
  end

  @spec obstacle_count(config(), pos_integer()) :: config()
  def obstacle_count(config, count) do
    config |> Map.put(:obstacle_count, count)
  end
end
