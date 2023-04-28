defmodule Strive.Systems.GameEnder do
  @moduledoc """
  Documentation for GameEnder system.
  """
  @behaviour ECSx.System

  alias Strive.Components.GameFinishedAt
  alias Strive.Components.GameLength
  alias Strive.Components.GameStartedAt

  def run do
    now = DateTime.utc_now()

    GameStartedAt.get_all()
    |> Enum.filter(&time_expired?(&1, now))
    |> Enum.each(&finish_game(&1, now))
  end

  defp time_expired?({game, started_at}, now) do
    length = GameLength.get_one(game)
    DateTime.diff(now, started_at) > length
  end

  defp finish_game({game, _}, now) do
    GameStartedAt.remove(game)
    GameFinishedAt.add(game, now)
  end
end
