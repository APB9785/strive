defmodule Strive.Specials do
  @data %{
    bribe: %{
      cost: [gold: 1000],
      vp_reward: 1,
      effects: [favor: -500]
    },
    mercenary: %{
      cost: [gold: 100],
      effects: [might: +500]
    },
    cartography: %{
      cost: [gold: 100],
      effects: [supplies_rate: +1]
    },
    prophet: %{
      cost: [gold: 100],
      effects: [favor_rate: +1]
    },
    raid: %{
      cost: [supplies: 500, might: 1000],
      effects: [favor: -500],
      attack: [gold: {10, :percent}]
    },
    blessing: %{
      vp_reward: 1,
      requirements: [favor: 10_000]
    },
    mine: %{
      cost: [gold: 100],
      effects: [gold_rate: +1]
    },
    blacksmith: %{
      cost: [gold: 200],
      effects: [might_rate: +1, supplies_rate: +1]
    },
    high_priest: %{
      cost: [gold: 100],
      requirements: [favor: 1000],
      effects: [favor: {20, :per_second}]
    }
  }
end
