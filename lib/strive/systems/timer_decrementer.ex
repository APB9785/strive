defmodule Strive.Systems.TimerDecrementer do
  @moduledoc """
  Documentation for TimerDecrementer system.
  """
  @behaviour ECSx.System

  alias Strive.Components.GameLength
  alias Strive.Components.GameStartedAt
  alias Strive.Components.SecondsRemaining

  def run do
    for {game, started_at} <- GameStartedAt.get_all() do
      elapsed =
        DateTime.utc_now()
        |> DateTime.diff(started_at, :millisecond)
        |> div(1000)

      length = GameLength.get_one(game)
      remaining = max(length - elapsed, 0)

      SecondsRemaining.update(game, remaining)
    end

    :ok
  end
end
