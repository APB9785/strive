defmodule Strive.Components.SecondsRemaining do
  @moduledoc """
  Documentation for SecondsRemaining components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
