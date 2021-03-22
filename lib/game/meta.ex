defmodule Engine2048.Game.Meta do
  alias Engine2048.Board
  alias Engine2048.Game.GRow

  @type tile_meta :: %{
          optional(:new) => boolean(),
          optional(:merged) => boolean(),
          optional(:delta) => {non_neg_integer(), non_neg_integer()},
          optional(:pv) => integer(),
          v: integer(),
          i: non_neg_integer()
        }

  @spec calc_row_diff(GRow.t(), GRow.t()) :: [tile_meta()] | nil
  def calc_row_diff(r1, r2) do
    if r1 == r2 do
      nil
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
      []
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
      IO.inspect(zero_boundary_index, label: "zero boundary index")
      IO.inspect(reverse_zero_boundary_index, label: "reverse zero boundary index")

      indexed_r2 =
        r2
        |> Enum.with_index()
        |> Enum.take(zero_boundary_index + 1)
        |> Enum.filter(fn {v, _} -> v > 0 end)

      IO.inspect(indexed_r2)

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

      IO.inspect(merge_indeces, label: "merge_indeces")

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
end
