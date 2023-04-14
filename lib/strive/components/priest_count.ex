defmodule Strive.Components.PriestCount do
  @moduledoc """
  Documentation for PriestCount components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
