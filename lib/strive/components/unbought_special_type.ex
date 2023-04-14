defmodule Strive.Components.UnboughtSpecialType do
  @moduledoc """
  Key:   special entity
  Value: type of special
  """
  use ECSx.Component,
    value: :atom,
    unique: true
end
