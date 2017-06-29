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

## List of assigning functions

#### build_child/1

``` elixir
comment = %Comment{ id: 17, path: [89] }
Comment.build_child(comment) # => %Comment{ id: nil, path: [17, 89] }
```

## List of fetching functions

Pass schema to them

``` elixir
# parent           Returns the parent of the record, nil for a root node
# parent_id        Returns the id of the parent of the record, nil for a root node
root             Returns the root of the tree the record is in, self for a root node
root_id          Returns the id of the root of the tree the record is in
root?            Returns true if the record is a root node, false otherwise
ancestor_ids     Returns a list of ancestor ids, starting with the root id and ending with the parent id
ancestors        Scopes the model on ancestors of the record
# path_ids         Returns a list the path ids, starting with the root id and ending with the node's own id
# path             Scopes model on path records of the record
# children         Scopes the model on children of the record
# child_ids        Returns a list of child ids
# siblings         Scopes the model on siblings of the record, the record itself is included*
# sibling_ids      Returns a list of sibling ids
# descendants      Scopes the model on direct and indirect children of the record
# descendant_ids   Returns a list of a descendant ids
# subtree          Scopes the model on descendants and itself
# subtree_ids      Returns a list of all ids in the record's subtree
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
