defmodule Strive.Systems.StandardGenerator do
  @moduledoc """
  Documentation for StandardGenerator system.
  """
  @behaviour ECSx.System

  alias Strive.Components.GameFinishedAt
  alias Strive.Components.PlayerJoined
  alias Strive.Components.CurrentFavor
  alias Strive.Components.CurrentGold
  alias Strive.Components.CurrentMight
  alias Strive.Components.CurrentSupplies
  alias Strive.Components.HunterCount
  alias Strive.Components.MineCount
  alias Strive.Components.PriestCount
  alias Strive.Components.SoldierCount

  @rate_per_second 1

  def run do
    rate = @rate_per_second / ECSx.tick_rate()

    for {player, soldier_count} <- SoldierCount.get_all(), player_game_not_finished?(player) do
      current_might = CurrentMight.get_one(player)
      CurrentMight.add(player, soldier_count * rate + current_might)
    end

    for {player, hunter_count} <- HunterCount.get_all(), player_game_not_finished?(player) do
      current_supplies = CurrentSupplies.get_one(player)
      CurrentSupplies.add(player, hunter_count * rate + current_supplies)
    end

    for {player, priest_count} <- PriestCount.get_all(), player_game_not_finished?(player) do
      current_favor = CurrentFavor.get_one(player)
      CurrentFavor.add(player, priest_count * rate + current_favor)
    end

    for {player, mine_count} <- MineCount.get_all(), player_game_not_finished?(player) do
      current_gold = CurrentGold.get_one(player)
      CurrentGold.add(player, mine_count * rate + current_gold)
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
