defmodule Strive.Components.GameFinishedAt do
  @moduledoc """
  Documentation for GameFinishedAt components.
  """
  use ECSx.Component,
    value: :datetime,
    unique: true
end
