defmodule StriveWeb.LobbyLive do
  @moduledoc false
  use StriveWeb, :live_view

  alias Strive.Components.GameLength
  alias Strive.Components.GameSize
  alias Strive.Components.GameWaiting
  alias Strive.Components.PlayerJoined

  require Logger

  @form_defaults %{"length" => 5, "size" => 4}

  def mount(_params, %{"player_token" => token} = _session, socket) do
    player = Strive.Players.get_player_by_session_token(token)

    socket =
      socket
      |> assign(player_entity: player.id, form: @form_defaults)
      |> assign_games_waiting()

    if connected?(socket) do
      :timer.send_interval(250, :refresh)
    end

    Logger.info("Mounting lobby for player #{player.id}")

    {:ok, socket}
  end

  def handle_info(:refresh, socket) do
    {:noreply, assign_games_waiting(socket)}
  end

  defp assign_games_waiting(socket) do
    games_waiting = GameWaiting.get_all()

    info =
      Enum.map(games_waiting, fn game ->
        %{
          id: game,
          time: GameLength.get_one(game),
          players: game |> PlayerJoined.get_all() |> length(),
          size: GameSize.get_one(game)
        }
      end)

    assign(socket, games_waiting: info)
  end

  def handle_event("join_game", %{"id" => game_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/game?id=#{game_id}")}
  end

  def handle_event("create_game", %{"length" => length, "size" => size}, socket) do
    player = socket.assigns.player_entity
    game_id = Ecto.UUID.generate()
    length = String.to_integer(length) * 60
    size = String.to_integer(size)
    ECSx.ClientEvents.add(player, {:create_new_game, game_id, length, size})

    {:noreply, push_navigate(socket, to: ~p"/game?id=#{game_id}")}
  end

  def render(assigns) do
    ~H"""
    <.modal id="create-modal">
      <p>Create new game</p>
      <.simple_form for={@form} phx-submit="create_game">
        <.input
          field={@form[:length]}
          label="Game length (minutes)"
          value={5}
          type="number"
          name="length"
        />
        <.input field={@form[:size]} label="Number of players" value={4} type="number" name="size" />
        <:actions>
          <.button>Create</.button>
        </:actions>
      </.simple_form>
    </.modal>
    <div>
      <div
        class="border border-black cursor-pointer bg-blue-500 rounded-xl w-fit px-4 py-2"
        phx-click={show_modal("create-modal")}
      >
        Create New Game
      </div>
      <div class="my-4">Join Game:</div>
      <%= for %{id: game_id, time: time, players: players, size: size} <- @games_waiting do %>
        <div
          class="border border-black bg-blue-300 rounded-xl my-4 p-2"
          phx-click="join_game"
          phx-value-id={game_id}
        >
          <p>Game Length: <%= div(time, 60) %> minutes</p>
          <p>Players: <%= players %>/<%= size %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
