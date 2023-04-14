defmodule Strive.Components.GameStartedAt do
  @moduledoc """
  Documentation for Game components.
  """
  use ECSx.Component,
    value: :datetime,
    unique: true
end
