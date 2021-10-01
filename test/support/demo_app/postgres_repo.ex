defmodule DemoApp.PostgresRepo do
  use Ecto.Repo,
    otp_app: :ecto_materialized_path,
    adapter: Ecto.Adapters.Postgres
end
