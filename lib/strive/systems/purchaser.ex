defmodule Strive.Systems.Purchaser do
  @moduledoc """
  Documentation for Purchaser system.
  """
  use ECSx.System

  alias Strive.Components.CurrentGold
  alias Strive.Components.HunterCount
  alias Strive.Components.PriestCount
  alias Strive.Components.SoldierCount
  alias Strive.Components.SpecialSelection
  alias Strive.Components.StandardSelection
  alias Strive.Components.UnboughtSpecial

  @cost 10
  @special_cost 20

  def run do
    Enum.each(StandardSelection.get_all(), &maybe_purchase/1)

    SpecialSelection.get_all()
    |> Enum.map(&validate_special_unbought/1)
    |> Enum.each(&maybe_purchase/1)
  end

  defp validate_special_unbought({player, selection}) do
    case UnboughtSpecial.get_one(selection) do
      nil ->
        SpecialSelection.remove(player)
        nil

      special ->
        {player, special}
    end
  end

  defp maybe_purchase(nil), do: :noop

  defp maybe_purchase({player, selection}) when is_atom(selection) do
    if CurrentGold.get_one(player) >= @cost do
      purchase(player, selection)
    end
  end

  defp maybe_purchase({player, special}) when is_binary(special) do
    if CurrentGold.get_one(player) >= @special_cost do
      purchase(player, special)
    end
  end

  defp purchase(player, :soldier) do
    current = SoldierCount.get_one(player)
    SoldierCount.add(player, current + 1)
    StandardSelection.remove(player)
    decrement_gold(player, @cost)
  end

  defp purchase(player, :hunter) do
    current = HunterCount.get_one(player)
    HunterCount.add(player, current + 1)
    StandardSelection.remove(player)
    decrement_gold(player, @cost)
  end

  defp purchase(player, :priest) do
    current = PriestCount.get_one(player)
    PriestCount.add(player, current + 1)
    StandardSelection.remove(player)
    decrement_gold(player, @cost)
  end

  defp purchase(_player, _special) do
    :noop
  end

  defp decrement_gold(player, amount) do
    current = CurrentGold.get_one(player)
    CurrentGold.add(player, current - amount)
  end
end
