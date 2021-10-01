import Config

config :ecto_materialized_path,
  ecto_repos: [
    DemoApp.PostgresRepo,
    DemoApp.MyXQLRepo
  ]

config :ecto_materialized_path, DemoApp.PostgresRepo,
  username: "postgres",
  password: "postgres",
  database: "demo_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :ecto_materialized_path, DemoApp.MyXQLRepo,
  username: "root",
  password: "root",
  database: "demo_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
