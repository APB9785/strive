defmodule Strive.Components.HunterCount do
  @moduledoc """
  Documentation for HunterCount components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
