defmodule DemoApp.PostgresNode do
  use Ecto.Schema

  use EctoMaterializedPath,
    column_name: :path,
    adapter: EctoMaterializedPath.Adapters.Postgres

  schema "nodes" do
    field :path, EctoMaterializedPath.Path, default: []
  end
end
