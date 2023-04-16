defmodule Strive.Components.GameLength do
  @moduledoc """
  Measured in seconds.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
