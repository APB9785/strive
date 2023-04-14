defmodule Strive.Systems.GameStarter do
  @moduledoc """
  Documentation for GameStarter system.
  """
  use ECSx.System

  alias Strive.Components.GameStartedAt
  alias Strive.Components.CurrentFavor
  alias Strive.Components.CurrentGold
  alias Strive.Components.CurrentMight
  alias Strive.Components.CurrentSupplies
  alias Strive.Components.GameSize
  alias Strive.Components.GameWaiting
  alias Strive.Components.HunterCount
  alias Strive.Components.MineCount
  alias Strive.Components.PlayerJoined
  alias Strive.Components.PriestCount
  alias Strive.Components.SoldierCount

  def run do
    game_waiting_ids = GameWaiting.get_all()

    Enum.each(game_waiting_ids, &maybe_start/1)
  end

  defp maybe_start(game) do
    with size when not is_nil(size) <- GameSize.get_one(game),
         players_joined when not is_nil(players_joined) <- PlayerJoined.get_all(game),
         true <- size == length(players_joined) do
      start(game, players_joined)
    end
  end

  defp start(game, players) do
    GameStartedAt.add(game, DateTime.utc_now())
    GameWaiting.remove(game)
    Enum.each(players, &init_player/1)
  end

  defp init_player(player) do
    CurrentFavor.add(player, 0.0)
    CurrentMight.add(player, 0.0)
    CurrentSupplies.add(player, 0.0)
    CurrentGold.add(player, 0.0)
    MineCount.add(player, 1)
    SoldierCount.add(player, 0)
    HunterCount.add(player, 0)
    PriestCount.add(player, 0)
  end
end