defmodule StriveWeb.GameLive do
  @moduledoc false
  use StriveWeb, :live_view

  alias Strive.Components.BoughtSpecial
  alias Strive.Components.CurrentFavor
  alias Strive.Components.CurrentGold
  alias Strive.Components.CurrentMight
  alias Strive.Components.CurrentSupplies
  alias Strive.Components.GameFinishedAt
  alias Strive.Components.GameLength
  alias Strive.Components.GameSize
  alias Strive.Components.GameStartedAt
  alias Strive.Components.HunterCount
  alias Strive.Components.PlayerJoined
  alias Strive.Components.PriestCount
  alias Strive.Components.SecondsRemaining
  alias Strive.Components.SoldierCount
  alias Strive.Components.SpecialSelection
  alias Strive.Components.StandardSelection
  alias Strive.Components.UnboughtSpecial

  require Logger

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
       started_at: nil,
       finished_at: nil,
       game_id: nil,
       players_joined: 0,
       game_size: 0,
       game_length: 0,
       seconds_remaining: nil,
       unbought_specials: [],
       player_specials: []
     )}
  end

  def unmount(metadata) do
    %{player: player, game: game} = metadata
    IO.inspect("Unmounting player #{player}")
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

    Logger.info("Mounting #{game_id} for player #{player.id}")

    {:noreply,
     assign(socket,
       player_entity: player.id,
       game_id: game_id,
       game_size: GameSize.get_one(game_id, nil),
       game_length: GameLength.get_one(game_id, nil)
     )}
  end

  def handle_info(:refresh, socket) do
    %{game_id: game, player_entity: player} = socket.assigns

    socket =
      case socket.assigns do
        %{started_at: nil, finished_at: nil} ->
          # Waiting for the game to start
          assign(socket,
            started_at: GameStartedAt.get_one(game, nil),
            players_joined: length(PlayerJoined.get_all(game)),
            game_size: GameSize.get_one(game, nil),
            game_length: GameLength.get_one(game, nil)
          )

        %{finished_at: nil} ->
          # Game is in progress
          assign(socket,
            current_gold: player |> CurrentGold.get_one() |> trunc(),
            current_might: player |> CurrentMight.get_one() |> trunc(),
            current_supplies: player |> CurrentSupplies.get_one() |> trunc(),
            current_favor: player |> CurrentFavor.get_one() |> trunc(),
            soldier_count: SoldierCount.get_one(player),
            hunter_count: HunterCount.get_one(player),
            priest_count: PriestCount.get_one(player),
            selector: StandardSelection.get_one(player, nil) || SpecialSelection.get_one(player, nil),
            seconds_remaining: SecondsRemaining.get_one(game),
            finished_at: GameFinishedAt.get_one(game, nil),
            unbought_specials: game |> UnboughtSpecial.get_all() |> Strive.Specials.parse(),
            player_specials: player |> BoughtSpecial.get_all() |> Strive.Specials.parse()
          )

        %{} ->
          # Game has finished
          socket
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

  def handle_event("select_special", %{"selection" => new_selection}, socket) do
    %{selector: current_selection, player_entity: player} = socket.assigns

    if current_selection == new_selection do
      ECSx.ClientEvents.add(player, :deselect)
    else
      ECSx.ClientEvents.add(player, {:select, new_selection})
    end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.link navigate={~p"/lobby"}>
      Return to Lobby
    </.link>
    <%= if @started_at do %>
      <div>
        <p>Time Remaining: <%= format_seconds(@seconds_remaining) %></p>
        <div id="unbought-specials" class="flex">
          <%= for %{entity: entity, name: name, description: description} <- @unbought_specials do %>
            <div
              class={standard_card_class(@selector, entity)}
              phx-click="select_special"
              phx-value-selection={entity}
            >
              <p><%= name %></p>
              <p><%= format_description(description) %></p>
            </div>
          <% end %>
        </div>
        <div id="player-stats">
          <p>Player Gold: <%= @current_gold %></p>
          <p>Player Might: <%= @current_might %></p>
          <p>Player Supplies: <%= @current_supplies %></p>
          <p>Player Favor: <%= @current_favor %></p>
        </div>

        <div id="standards" class="flex gap-x-4">
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

        <div id="player-specials" class="flex">
          <%= for %{entity: _entity, name: name, description: description} <- @player_specials do %>
            <div class={standard_card_class()}>
              <p><%= name %></p>
              <p><%= format_description(description) %></p>
            </div>
          <% end %>
        </div>
      </div>
    <% else %>
      <div>
        <p>Not started yet!</p>
        <p>Game length: <%= div(@game_length || 0, 60) %> minutes</p>
        <p>Players joined: <%= @players_joined %>/<%= @game_size %></p>
      </div>
    <% end %>
    """
  end

  defp format_description(description) do
    description
    |> String.split("\n", trim: false)
    |> Enum.intersperse(Phoenix.HTML.Tag.tag(:br))
  end

  defp format_seconds(nil), do: ""

  defp format_seconds(seconds) do
    mm = seconds |> div(60) |> Integer.to_string() |> String.pad_leading(2, "0")
    ss = seconds |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0")

    [mm, ":", ss]
  end

  defp standard_card_class do
    "cursor-pointer border border-black rounded-xl p-2"
  end

  defp standard_card_class(selector, type) do
    append = if selector == type, do: " border-orange-500 bg-amber-200", else: " border-black"

    ["cursor-pointer border rounded-xl p-2", append]
  end

  defp to_atom("soldier"), do: :soldier
  defp to_atom("hunter"), do: :hunter
  defp to_atom("priest"), do: :priest
end
