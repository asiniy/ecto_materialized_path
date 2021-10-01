defmodule DemoApp.MyXQLRepo.Migrations.CreateNode do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :path, :json, null: false
    end
  end
end
