defmodule Engine2048 do
  @moduledoc """
    Main module that exposes an API to start and run a 2048 game. \n
    
    This module should suffice for most if not all use cases and there should be no need for interacting 
    with other modules.\n

  ## To get going...
       iex> Engine2048.quick_start()
  """
  alias Engine2048.{Game, Builder, Print}

  @type config() :: Game.game_config()
  @type state() :: Game.game_state()
  @type noop() :: Game.noop()
  @type swipe_dir() :: Game.swipe_dir()

  @spec quick_start() :: {:ok, state()}
  ## giving false warning

  @doc """
    Quick starts a quick game with the default configuration.


  ## Examples
      iex> {:ok, game_state} = Engine2048.quick_start()

  """
  def quick_start do
    Builder.new() |> Game.start()
  end

  @doc """
    Starts a game by passing configuration in.

  ## Examples
      iex> alias Engine2048.Builder, as: Builder
      iex> {:ok, game_state} = Builder.new() |> Builder.obstacle_count(3) |>Engine2048.start()

  """
  @spec start(config()) :: {:ok, state()}
  def start(config) do
    config |> Game.start()
  end

  @doc """
    Runs a swipe on the board. If the swipe leaves the board unchanged 
    noop will be set to true

  ## Examples
      iex> {:ok, state} = Engine2048.quick_start()
      iex> _ = Engine2048.swipe(state, :right)
  """
  @spec swipe(state(), swipe_dir()) :: state()
  def swipe(state, swipe_dir), do: Game.run_turn(state, swipe_dir)

  @doc """
    Signals the end of the game whenever `true` or `false` \n
    `nil` means that the game is not over.
  """
  @spec game_over?(state()) :: Game.victory()
  def game_over?(%{victory: victory}), do: victory

  @doc """
    Returns the score of the game
  """
  @spec score(state()) :: pos_integer()
  def score(state), do: state |> Game.score()

  @doc """
    Returns the number of turns elapsed
  """
  @spec turns(state()) :: pos_integer()
  def turns(%{turns: turns}), do: turns

  @doc """
    Checks if the swipe left the game unaffected
  """
  @spec noop?(state()) :: noop()
  def noop?(%{noop: noop}), do: noop

  @doc """
    Outputs both boards (prev and current) to the console \n
    The function is invoked inside the Game module and is currently a hardcoded behaviour
  """
  @spec print(state()) :: :ok
  def print(state), do: Print.print(state)
end
