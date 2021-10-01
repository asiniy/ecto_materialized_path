# `ecto_materialized_path`

[![Build Status](https://travis-ci.org/asiniy/ecto_materialized_path.svg?branch=master)](https://travis-ci.org/asiniy/ecto_materialized_path)
![badge](https://img.shields.io/hexpm/v/ecto_materialized_path.svg)

Allows you to store and organize your Ecto records in a tree structure (or an hierarchy). It uses a single database column, using the materialized path pattern. It exposes all the standard tree structure relations (ancestors, parent, root, children, siblings, descendants, depth) and all of them can be fetched in a single SQL query.

## Supported Databases

- PostgreSQL `> 9`
- MySQL `>= 5.7.8`

## Installation

Add following lines to your `mix.exs`:

```elixir
def deps do
  [{:ecto_materialized_path, "~> x.x.x"}]
end
```

## Basic Usage

### PostgreSQL

Create a migration:

```elixir
defmodule DemoApp.Repo.Migrations.CreateNode do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      # ...
      add :path, {:array, :integer}, null: false
    end
  end
end
```

Create a schema:

```elixir
defmodule DemoApp.Tree.Node do
  use EctoMaterializedPath,
    column_name: :path,
    adapter: EctoMaterizalizedPath.Adapters.Postgres

    schema "nodes" do
      # ...
      field :path, EctoMaterializedPath.Path, default: [] # default is important
    end
  end
end
```

### MySQL

Create a migration:

```elixir
defmodule DemoApp.MyXQLRepo.Migrations.CreateNode do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :path, :json, null: false
    end
  end
end
```

Create a schema:

```elixir
defmodule DemoApp.Tree.Node do
  use EctoMaterializedPath,
    column_name: :path,
    adapter: EctoMaterizalizedPath.Adapters.Postgres

    schema "nodes" do
      # ...
      field :path, EctoMaterializedPath.Path, default: [] # default is important
    end
  end
end
```

## Available Options

Options of `use EctoMaterializedPath`:

- `column_name` (default: `:path`) - the name of field which stores hierarchy data
- `adapter` - current available adapters:
  - `EctoMaterizalizedPath.Adapters.Postgres`
  - `EctoMaterizalizedPath.Adapters.MyXQL`

> Q: Why do you name the adapter of MySQL in this way?
>
> A: Because `Ecto` is using such name, and I want to keep the harmony between the `EctoMaterializedPath` and `Ecto`.

## How does it work?

`EctoMaterializedPath` stores node position as the path of its ancestors.

For example:

```elixir
%Node{ path: [] } # no ancestors => is root
%Node{ path: [1] } # this node is a child of node with id == 1
%Node{ path: [1, 3] } # this node is a child of the node with id == 3, which in its turn is the child of the node with id == 1
```

## License

Apache 2.0
