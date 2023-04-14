defmodule Strive.Components.GameLength do
  @moduledoc """
  Documentation for GameLength components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
