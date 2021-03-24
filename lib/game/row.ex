defmodule Engine2048.Game.GRow do
  alias Engine2048.Game.GRow

  alias Engine2048.Tile

  @type t :: [integer()]
  @type tile() :: Tile.t()

  @spec shift(t()) :: t()
  def shift(row) do
    case row |> Enum.chunk_by(&(&1 == -1)) do
      [] ->
        []

      ## chunk operation adds brackets around 
      ## [[]]
      wrapped_row ->
        ## no obstacles
        if wrapped_row |> length() == 1 do
          [row] = wrapped_row
          len = row |> length()

          f_row =
            row
            |> Enum.filter(&(&1 != 0))

          f_row
          |> pad_zeroes(len - (f_row |> length()))
        else
          wrapped_row |> Enum.map(&shift(&1)) |> List.flatten()
        end
    end
  end

  @spec pad_zeroes(t(), non_neg_integer()) :: t()
  defp pad_zeroes(row, 0), do: row

  defp pad_zeroes(row, count) do
    [0 | row] |> pad_zeroes(count - 1)
  end

  @spec merge(t()) :: t()
  def merge(row) do
    empty? = row |> Enum.all?(&(&1 == 0))
    len = row |> length()
    uniq_count = row |> Enum.uniq() |> length()
    all_distinct? = len == uniq_count
    # has_obstacles? == Enum.filter(&(&1 == -1)) |> length > 0

    cond do
      empty? || all_distinct? ->
        row

      true ->
        row |> Enum.reverse() |> do_merge() |> Enum.reverse()
    end
  end

  @spec do_merge(t(), pos_integer()) :: t()
  defp do_merge(row, i \\ 1) do
    len = row |> length()
    t1 = row |> Enum.at(i)
    t2 = row |> Enum.at(i - 1)

    cond do
      i > len ->
        row

      can_merge?(t1, t2) ->
        row
        |> List.replace_at(i - 1, t1 * 2)
        |> List.replace_at(i, 0)
        |> do_merge(i + 1)

      true ->
        row |> do_merge(i + 1)
    end
  end

  @spec swipe(t()) :: t()
  def swipe(row) do
    row
    |> shift()
    |> merge()
    |> shift()
  end

  @spec can_merge?(tile(), tile()) :: boolean()
  def can_merge?(t1, t2) do
    cond do
      t1 < 1 || t2 < 1 ->
        false

      t1 != t2 ->
        false

      true ->
        true
    end
  end
end
