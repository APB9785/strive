defmodule Strive.Components.GameStartedAt do
  @moduledoc """
  Documentation for GameStartedAt components.
  """
  use ECSx.Component,
    value: :datetime,
    unique: true
end
