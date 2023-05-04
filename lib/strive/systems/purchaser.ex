defmodule Strive.Systems.Purchaser do
  @moduledoc """
  Documentation for Purchaser system.
  """
  @behaviour ECSx.System

  alias Strive.Components.BoughtSpecial
  alias Strive.Components.CurrentFavor
  alias Strive.Components.CurrentGold
  alias Strive.Components.CurrentMight
  alias Strive.Components.CurrentSupplies
  alias Strive.Components.FavorRate
  alias Strive.Components.GoldRate
  alias Strive.Components.HunterCount
  alias Strive.Components.MightRate
  alias Strive.Components.PlayerJoined
  alias Strive.Components.PriestCount
  alias Strive.Components.SoldierCount
  alias Strive.Components.SpecialSelection
  alias Strive.Components.SpecialType
  alias Strive.Components.StandardSelection
  alias Strive.Components.SuppliesRate
  alias Strive.Components.UnboughtSpecial

  @cost 10

  def run do
    Enum.each(StandardSelection.get_all(), &maybe_purchase/1)

    SpecialSelection.get_all()
    |> Enum.map(&validate_special_unbought/1)
    |> Enum.each(&maybe_purchase/1)
  end

  defp validate_special_unbought({player, selection}) do
    case UnboughtSpecial.search(selection) do
      [] ->
        SpecialSelection.remove(player)
        nil

      [_game] ->
        {player, selection}
    end
  end

  defp maybe_purchase(nil), do: :noop

  defp maybe_purchase({player, selection}) when is_atom(selection) do
    if CurrentGold.get_one(player) >= @cost do
      purchase(player, selection)
    end
  end

  defp maybe_purchase({player, special}) when is_binary(special) do
    special_type = SpecialType.get_one(special)

    if can_afford_special?(player, special_type) and meets_requirements?(player, special_type) do
      purchase(player, special)
    end
  end

  defp can_afford_special?(player, special_type) do
    special_type
    |> Strive.Specials.costs()
    |> Enum.map(fn
      {:gold, gold} -> CurrentGold.get_one(player) >= gold
      {:might, might} -> CurrentMight.get_one(player) >= might
      {:supplies, supplies} -> CurrentSupplies.get_one(player) >= supplies
      {:favor, favor} -> CurrentFavor.get_one(player) >= favor
    end)
    |> Enum.all?(& &1)
  end

  defp meets_requirements?(player, special_type) do
    special_type
    |> Strive.Specials.requirements()
    |> Enum.map(fn
      {:gold, gold} -> CurrentGold.get_one(player) >= gold
      {:might, might} -> CurrentMight.get_one(player) >= might
      {:supplies, supplies} -> CurrentSupplies.get_one(player) >= supplies
      {:favor, favor} -> CurrentFavor.get_one(player) >= favor
    end)
    |> Enum.all?(& &1)
  end

  defp purchase(player, :soldier) do
    current = SoldierCount.get_one(player)
    SoldierCount.update(player, current + 1)
    StandardSelection.remove(player)
    change_current_gold(player, -@cost)
  end

  defp purchase(player, :hunter) do
    current = HunterCount.get_one(player)
    HunterCount.update(player, current + 1)
    StandardSelection.remove(player)
    change_current_gold(player, -@cost)
  end

  defp purchase(player, :priest) do
    current = PriestCount.get_one(player)
    PriestCount.update(player, current + 1)
    StandardSelection.remove(player)
    change_current_gold(player, -@cost)
  end

  defp purchase(player, special) when is_binary(special) do
    special_type = SpecialType.get_one(special)

    special_type
    |> Strive.Specials.costs()
    |> Enum.each(fn
      {:gold, n} -> change_current_gold(player, -n)
      {:might, n} -> change_current_might(player, -n)
      {:supplies, n} -> change_current_supplies(player, -n)
      {:favor, n} -> change_current_favor(player, -n)
    end)

    [game] = PlayerJoined.search(player)

    UnboughtSpecial.remove_one(game, special)
    BoughtSpecial.add(player, special)

    one_time_effects(special_type, player)

    Strive.Specials.generate_new(game)
  end

  defp one_time_effects(special_type, player) do
    special_type
    |> Strive.Specials.effects()
    |> Enum.each(fn
      {_, {_, :per_second}} -> :noop
      {:might_rate, n} -> change_might_rate(player, n)
      {:supplies_rate, n} -> change_supplies_rate(player, n)
      {:favor_rate, n} -> change_favor_rate(player, n)
      {:gold_rate, n} -> change_gold_rate(player, n)
      {:gold, n} -> change_current_gold(player, n)
      {:might, n} -> change_current_might(player, n)
      {:supplies, n} -> change_current_supplies(player, n)
      {:favor, n} -> change_current_favor(player, n)
    end)
  end

  defp change_current_gold(player, amount) do
    current = CurrentGold.get_one(player)
    CurrentGold.update(player, current + amount)
  end

  defp change_current_might(player, amount) do
    current = CurrentMight.get_one(player)
    CurrentMight.update(player, current + amount)
  end

  defp change_current_supplies(player, amount) do
    current = CurrentSupplies.get_one(player)
    CurrentSupplies.update(player, current + amount)
  end

  defp change_current_favor(player, amount) do
    current = CurrentFavor.get_one(player)
    CurrentFavor.update(player, current + amount)
  end

  defp change_gold_rate(player, amount) do
    current = GoldRate.get_one(player)
    GoldRate.update(player, current + amount)
  end

  defp change_might_rate(player, amount) do
    current = MightRate.get_one(player)
    MightRate.update(player, current + amount)
  end

  defp change_supplies_rate(player, amount) do
    current = SuppliesRate.get_one(player)
    SuppliesRate.update(player, current + amount)
  end

  defp change_favor_rate(player, amount) do
    current = FavorRate.get_one(player)
    FavorRate.update(player, current + amount)
  end
end
