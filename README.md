# Engine2048

Elixir project encapsulating the logic to play the infamous 2048 game with some caveats (read further down).

The game is stateless and makes no assumptions about the game's statefulness and it can be used as an engine to
power up a 2048-game application.

It does not matter who is playing the game or when is it being played due to its stateless nature. There is the possibility of saving the game state somewhere and continue to play the game later on - or 10 years from now.

It can be played on the CLI by running `iex -S mix` as it is a very simple Elixir application with a small API

## Installation

The game can be installed by adding the github repo to the deps array. No further details are given since this is part of an assignment for the time being.

## Docs

To generate the docs locally run `mix docs` and open up the `index.html` file.

## Testing

The project has been amply tested and should work under all conditions.

## Caveats

For the time being the game will start with a single tile of a configurable value. The same can be said for the new tile that will spawn after a turn is completed. The game's `max_value` can be chosen so as to change the difficulty of the game.\n

Keep in mind that the game will terminate upon reaching the `max_value` (defaulting to `2048`) or when all tiles have been filled in.

## The software itself

### Typespecs

A great emphasis was placed upon adding typespecs, which is not mandatory in Elixir. It is very helpful however to have a module return a limited family to facilitate function chaining - one of Elixir's greatest strengths. It also helps to transition into a language that is statically typed.

### Possible Extensions

The game could be easily extended by passing anonymous functions where the victory conditions are evaluated or where the score is calculated (or even both).

It would not be difficult to implement power-ups that could be used during certain turns to either remove some tiles or change a tile to a particular value. The `Board` module exposes an API that can be used to interact with the board while running a turn.

Lookahead logic could be implemented by running the turn and obtaining the next state of the game, after running said turn. With said logic, one could write a simple program to play the game on its own against another player (race against the clock) or to provide move suggestions.

### Why Elixir?

A game like 2048 is a great fit for a functional paradigm (fewer bugs due to no state).

Elixir's own `Enum` module (or for any logic built upon it) along with the `|>` operator are great tools in the developer's arsenal to write code that decouples data from flow control.

This project can be plugged in into another other project to serve single-player or multi-player games.

### Implementation and primitives

The board and the game themselves were implemented using simple lists while tile values are represented with just integers. Even though there are modules wrapping the logic of the game, no additional effort was made to create complex structs which resulted in some parts of the implementation to be lighter on the eyes, and both easier to read and maintain. Typed maps (with typespecs) and pattern matching were preferred to structs.

The board, the most important data structure of the game, is represented as a list of a list of integers, as this is probably the most natural abstraction.

### What if not Elixir?

A game of this sort could have been easier to write in a language with a more algebraic, static type system.

## Criticism

The documentation is a bit lacking and the types must be cleaned up as there are some private modules exposing some of their types.

The use of more guards could have been beneficial to catch errors. Custom guards would also have been useful in tightening the logic, for example where only positive integers are accepted.
