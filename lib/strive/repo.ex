defmodule Strive.Repo do
  use Ecto.Repo,
    otp_app: :strive,
    adapter: Ecto.Adapters.Postgres
end
