defmodule Strive.Components.BoughtSpecial do
  @moduledoc """
  Key:   player entity
  Value: special entity
  """
  use ECSx.Component,
    value: :binary,
    unique: false
end
