defmodule Strive.Systems.ClientEventHandler do
  @moduledoc """
  Documentation for ClientEventHandler system.
  """
  use ECSx.System

  alias Strive.Components.StandardSelection
  alias Strive.Components.GameLength
  alias Strive.Components.GameSize
  alias Strive.Components.GameWaiting
  alias Strive.Components.PlayerJoined

  def run do
    client_events = ECSx.ClientEvents.get_and_clear()

    Enum.each(client_events, &process_one/1)
  end

  defp process_one({player, :deselect}) do
    StandardSelection.remove(player)
  end

  defp process_one({player, {:select, selection}}) when is_atom(selection) do
    StandardSelection.add(player, selection)
  end

  defp process_one({_player, {:create_new_game, id, length, size}}) do
    GameWaiting.add(id)
    GameLength.add(id, length)
    GameSize.add(id, size)
  end

  defp process_one({player, {:join_game, game}}) do
    PlayerJoined.add(game, player)
  end

  defp process_one({player, {:left_game, game}}) do
    PlayerJoined.remove_one(game, player)

    if PlayerJoined.get_all(game) == [] do
      GameWaiting.remove(game)
      GameLength.remove(game)
      GameSize.remove(game)
    end
  end
end
