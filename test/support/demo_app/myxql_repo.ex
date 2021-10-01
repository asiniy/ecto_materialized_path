defmodule DemoApp.MyXQLRepo do
  use Ecto.Repo,
    otp_app: :ecto_materialized_path,
    adapter: Ecto.Adapters.MyXQL
end
