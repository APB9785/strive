defmodule Strive.Specials do
  @moduledoc false
  alias Strive.Components.SpecialType

  @data %{
    bribe: %{
      name: "Bribe",
      cost: [gold: 1000],
      vp_reward: 1,
      effects: [favor: -500],
      description: """
      Cost: 1000 gold
      +1 VP
      -500 Favor
      """
    },
    mercenary: %{
      name: "Mercenary",
      cost: [gold: 100],
      effects: [might: +500],
      description: """
      Cost: 100 gold
      +500 Might
      """
    },
    cartography: %{
      name: "Cartography",
      cost: [gold: 100],
      effects: [supplies_rate: +1],
      description: """
      Cost: 100 gold
      Hunters generate +1
      additional Supplies
      per second.
      """
    },
    prophet: %{
      name: "Prophet",
      cost: [gold: 100],
      effects: [favor_rate: +1],
      description: """
      Cost: 100 gold
      Priests generate +1
      additional Favor
      per second.
      """
    },
    raid: %{
      name: "Raid",
      cost: [supplies: 500, might: 1000],
      effects: [favor: -500],
      attack: [gold: {10, :percent}],
      description: """
      Cost: 500 Supplies
      Cost: 1000 Might
      Steal 10% of each
      opponent's current
      gold total.
      """
    },
    blessing: %{
      name: "Blessing",
      cost: [gold: 50, supplies: 500],
      vp_reward: {1, per: :favor},
      description: """
      Cost: 50 gold
      Cost: 500 supplies
      +1 VP per 1000 Favor
      """
    },
    mine: %{
      name: "Mine",
      cost: [gold: 100],
      effects: [gold_rate: +1],
      description: """
      Cost: 100 gold
      +1 Gold per second
      """
    },
    blacksmith: %{
      name: "Blacksmith",
      cost: [gold: 200],
      effects: [might_rate: +1, supplies_rate: +1],
      description: """
      Cost: 200 gold
      Soldiers and Hunters
      generate +1 additional
      Might/Supplies per
      second.
      """
    },
    high_priest: %{
      name: "High Priest",
      cost: [gold: 100],
      requirements: [favor: 1000],
      effects: [favor: {20, :per_second}],
      description: """
      Cost: 100 gold
      Requires: 1000+ Favor
      +20 Favor per second
      """
    }
  }

  def data, do: @data

  def parse(specials) when is_list(specials) do
    for special <- specials do
      type = SpecialType.get_one(special)

      %{
        entity: special,
        name: @data[type][:name],
        description: @data[type][:description]
      }
    end
  end
end
