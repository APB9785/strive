defmodule Strive.Components.PlayerJoined do
  @moduledoc """
  Key:   Game
  Value: Player
  """
  use ECSx.Component,
    value: :binary,
    unique: false
end
