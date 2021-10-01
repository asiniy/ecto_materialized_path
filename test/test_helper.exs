ExUnit.start()

{:ok, _pid} = DemoApp.PostgresRepo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(DemoApp.PostgresRepo, :manual)

{:ok, _pid} = DemoApp.MyXQLRepo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(DemoApp.MyXQLRepo, :manual)
