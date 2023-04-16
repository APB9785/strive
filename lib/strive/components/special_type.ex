defmodule Strive.Components.SpecialType do
  @moduledoc """
  Key:   special entity
  Value: type of special
  """
  use ECSx.Component,
    value: :atom,
    unique: true
end
