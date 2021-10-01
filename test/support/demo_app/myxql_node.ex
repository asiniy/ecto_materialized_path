defmodule DemoApp.MyXQLNode do
  use Ecto.Schema

  use EctoMaterializedPath,
    column_name: :path,
    adapter: EctoMaterializedPath.Adapters.MyXQL

  schema "nodes" do
    field :path, EctoMaterializedPath.Path, default: []
  end
end
