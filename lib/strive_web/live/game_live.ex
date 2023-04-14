defmodule StriveWeb.GameLive do
  @moduledoc false
  use StriveWeb, :live_view

  alias Strive.Components.CurrentFavor
  alias Strive.Components.CurrentGold
  alias Strive.Components.CurrentMight
  alias Strive.Components.CurrentSupplies
  alias Strive.Components.GameLength
  alias Strive.Components.GameSize
  alias Strive.Components.GameStartedAt
  alias Strive.Components.HunterCount
  alias Strive.Components.PlayerJoined
  alias Strive.Components.PriestCount
  alias Strive.Components.SoldierCount
  alias Strive.Components.StandardSelection

  def mount(_params, %{"player_token" => token} = _session, socket) do
    {:ok,
     assign(socket,
       player_token: token,
       player_entity: nil,
       selector: nil,
       current_gold: 0.0,
       current_might: 0.0,
       current_supplies: 0.0,
       current_favor: 0.0,
       soldier_count: 0,
       hunter_count: 0,
       priest_count: 0,
       started: false,
       game_id: nil,
       players_joined: 0,
       game_size: 0,
       game_length: 0
     )}
  end

  def unmount(metadata) do
    IO.inspect("unmounting!")
    %{player: player, game: game} = metadata
    ECSx.ClientEvents.add(player, {:left_game, game})
  end

  def handle_params(%{"id" => game_id}, _uri, socket) do
    player =
      if connected?(socket) do
        player = Strive.Players.get_player_by_session_token(socket.assigns.player_token)
        StriveWeb.LiveMonitor.monitor(self(), __MODULE__, %{player: player.id, game: game_id})
        ECSx.ClientEvents.add(player.id, {:join_game, game_id})
        :timer.send_interval(250, :refresh)
        player
      else
        %{id: nil}
      end

    {:noreply,
     assign(socket,
       player_entity: player.id,
       game_id: game_id,
       game_size: GameSize.get_one(game_id),
       game_length: GameLength.get_one(game_id)
     )}
  end

  def handle_info(:refresh, socket) do
    socket =
      if socket.assigns.started do
        player = socket.assigns.player_entity

        assign(socket,
          current_gold: CurrentGold.get_one(player),
          current_might: CurrentMight.get_one(player),
          current_supplies: CurrentSupplies.get_one(player),
          current_favor: CurrentFavor.get_one(player),
          soldier_count: SoldierCount.get_one(player),
          hunter_count: HunterCount.get_one(player),
          priest_count: PriestCount.get_one(player),
          selector: StandardSelection.get_one(player)
        )
      else
        game_id = socket.assigns.game_id

        assign(socket,
          started: GameStartedAt.exists?(game_id),
          players_joined: length(PlayerJoined.get_all(game_id)),
          game_size: GameSize.get_one(game_id),
          game_length: GameLength.get_one(game_id)
        )
      end

    {:noreply, socket}
  end

  def handle_event("select", %{"selection" => selection}, socket) do
    %{selector: current_selection, player_entity: player} = socket.assigns

    case to_atom(selection) do
      ^current_selection -> ECSx.ClientEvents.add(player, :deselect)
      new_selection -> ECSx.ClientEvents.add(player, {:select, new_selection})
    end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.link navigate={~p"/lobby"}>
      Return to Lobby
    </.link>
    <%= if @started do %>
      <div>
        <p>Player Gold: <%= trunc(@current_gold) %></p>
        <p>Player Might: <%= trunc(@current_might) %></p>
        <p>Player Supplies: <%= trunc(@current_supplies) %></p>
        <p>Player Favor: <%= trunc(@current_favor) %></p>

        <div class="flex gap-x-4">
          <div
            phx-click="select"
            phx-value-selection="soldier"
            class={standard_card_class(@selector, :soldier)}
          >
            <p>Soldier</p>
            <p>Generates Might (1/sec)</p>
            <p>Cost: 10 gold</p>
            <p>You have: <%= @soldier_count %></p>
          </div>
          <div
            phx-click="select"
            phx-value-selection="hunter"
            class={standard_card_class(@selector, :hunter)}
          >
            <p>Hunter</p>
            <p>Generates Supplies (1/sec)</p>
            <p>Cost: 10 gold</p>
            <p>You have: <%= @hunter_count %></p>
          </div>
          <div
            phx-click="select"
            phx-value-selection="priest"
            class={standard_card_class(@selector, :priest)}
          >
            <p>Priest</p>
            <p>Generates Favor (1/sec)</p>
            <p>Cost: 10 gold</p>
            <p>You have: <%= @priest_count %></p>
          </div>
        </div>
      </div>
    <% else %>
      <div>
        <p>Not started yet!</p>
        <p>Game length: <%= @game_length %> minutes</p>
        <p>Players joined: <%= @players_joined %>/<%= @game_size %></p>
      </div>
    <% end %>
    """
  end

  defp standard_card_class(selector, type) do
    append = if selector == type, do: " border-orange-500 bg-amber-200", else: " border-black"

    ["cursor-pointer border rounded-xl p-2", append]
  end

  defp to_atom("soldier"), do: :soldier
  defp to_atom("hunter"), do: :hunter
  defp to_atom("priest"), do: :priest
end
