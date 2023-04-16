defmodule Strive.Components.UnboughtSpecial do
  @moduledoc """
  Key:   room entity
  Value: special entity
  """
  use ECSx.Component,
    value: :binary,
    unique: false
end
