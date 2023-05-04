defmodule Strive.Components.FavorRate do
  @moduledoc """
  Documentation for FavorRate components.
  """
  use ECSx.Component,
    value: :integer,
    unique: true
end
