defmodule Strive.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  setup do
    # Load your initial components
  end

  # Declare all valid Component types
  def components do
    [
      Strive.Components.GameFinishedAt,
      Strive.Components.GameStartedAt,
      Strive.Components.SecondsRemaining,
      Strive.Components.GameLength,
      Strive.Components.GameSize,
      Strive.Components.PlayerJoined,
      Strive.Components.GameWaiting,
      Strive.Components.MineCount,
      Strive.Components.CurrentGold,
      Strive.Components.SpecialSelection,
      Strive.Components.StandardSelection,
      Strive.Components.SpecialType,
      Strive.Components.CurrentFavor,
      Strive.Components.CurrentSupplies,
      Strive.Components.CurrentMight,
      Strive.Components.BoughtSpecial,
      Strive.Components.UnboughtSpecial,
      Strive.Components.PriestCount,
      Strive.Components.HunterCount,
      Strive.Components.SoldierCount
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      Strive.Systems.TimerDecrementer,
      Strive.Systems.GameEnder,
      Strive.Systems.GameStarter,
      Strive.Systems.ClientEventHandler,
      Strive.Systems.Purchaser,
      Strive.Systems.SpecialGenerator,
      Strive.Systems.StandardGenerator
    ]
  end
end
