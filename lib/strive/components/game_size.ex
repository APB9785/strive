defmodule Strive.Components.GameSize do
  @moduledoc """
  Documentation for GameSize components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
