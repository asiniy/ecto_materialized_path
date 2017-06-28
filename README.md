# EctoMaterializedPath

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_materialized_path` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ecto_materialized_path, "~> 0.1.0"}]
end
```

### Namespace

You can namespace all your functions on a module, it's very suitable when schema belongs to a couple of trees or in the case of function name conflicts. Just do:

``` elixir
use EctoMaterializedPath,
  namespace: "brutalist"
```

And you will have all functions namespaced:

``` elixir
Comment.brutalist_root
Comment.brutalist_root?
# et.c.
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_materialized_path](https://hexdocs.pm/ecto_materialized_path).
