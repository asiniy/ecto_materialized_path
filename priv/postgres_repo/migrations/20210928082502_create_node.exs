defmodule DemoApp.PostgresRepo.Migrations.CreateNode do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :path, {:array, :integer}, null: false
    end
  end
end
