defmodule Strive.Components.StartedAt do
  @moduledoc """
  Documentation for StartedAt components.
  """
  use ECSx.Component,
    value: :datetime,
    unique: true
end
