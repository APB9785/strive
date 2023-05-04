defmodule Strive.Systems.SpecialGenerator do
  @moduledoc """
  Documentation for SpecialGenerator system.
  """
  @behaviour ECSx.System

  alias Strive.Components.BoughtSpecial
  alias Strive.Components.CurrentFavor
  alias Strive.Components.GameFinishedAt
  alias Strive.Components.PlayerJoined
  alias Strive.Components.SpecialType

  def run do
    for {player, special} <- BoughtSpecial.get_all(), player_game_not_finished?(player) do
      special
      |> SpecialType.get_one()
      |> Strive.Specials.effects()
      |> Enum.each(fn
        {:favor, {n, :per_second}} ->
          amount = n / ECSx.tick_rate()
          current_favor = CurrentFavor.get_one(player)
          CurrentFavor.update(player, amount + current_favor)

        _ ->
          :noop
      end)
    end

    :ok
  end

  defp player_game_not_finished?(player) do
    case PlayerJoined.search(player) do
      [game] -> !GameFinishedAt.exists?(game)
      _ -> false
    end
  end
end
