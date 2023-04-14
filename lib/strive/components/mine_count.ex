defmodule Strive.Components.MineCount do
  @moduledoc """
  Documentation for MineCount components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
