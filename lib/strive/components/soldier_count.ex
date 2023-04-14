defmodule Strive.Components.SoldierCount do
  @moduledoc """
  Documentation for SoldierCount components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
