# `ecto_materialized_path`

[![Build Status](https://travis-ci.org/asiniy/ecto_materialized_path.svg?branch=master)](https://travis-ci.org/asiniy/ecto_materialized_path)
![badge](https://img.shields.io/hexpm/v/ecto_materialized_path.svg)

Allows you to store and organize your Ecto records in a tree structure (or an hierarchy). It uses a single database column, using the materialized path pattern. It exposes all the standard tree structure relations (ancestors, parent, root, children, siblings, descendants, depth) and all of them can be fetched in a single SQL query.

## Installation

`mix.exs`

```elixir
def deps do
  [{:ecto_materialized_path, "~> x.x.x"}]
end
```


## Getting started

`use EctoMaterializedPath` in your schema. It takes 2 arguments:

  * `column_name` (default: `"path"`): the name of the database column which stores hierarchy data;
  * `namespace` (default: `nil`): you can namespace your functions if you have some naming conflicts. [Details](#namespace)

``` elixir
defmodule Comment do
  use MyApp.Web, :model

  use EctoMaterializedPath

  schema "comments" do
    field :path, EctoMaterializedPath.Path, default: [] # default is important here
  end
end
```

Write a migration for this functionality

``` elixir
defmodule MyApp.AddMaterializedPathToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :path, {:array, :integer}, null: false
    end
  end
end
```

## How does it work?

`ecto_materialized_path` stores node position as the tree of its ancestors, i.e.

``` elixir
%Comment{ path: [] } # no ancestors => is root
%Comment{ path: [1] } # this comment is a child of comment with id == 1
%Comment{ path: [1, 3] } # this comment is a child of the comment with id == 3, which in its turn is the child of the comment with id == 1
```

Only postgresql `> 9.x` supports array as the stored field, so that `ecto_materialized_path` is compatible with postgresql only.

## Assigning functions

Are usable when you need to assign some schema as a child of another schema

#### `build_child/1`

``` elixir
comment = %Comment{ id: 17, path: [89] }
Comment.build_child(comment)
# => %Comment{ id: nil, path: [17, 89] }
```

#### `make_child_of/2`

Takes a struct (or changeset) and parent struct; returns changeset with correct path.

``` elixir
comment = %Comment{ id: 17, path: [] } # or comment |> Ecto.Changeset.change(%{})
parent_comment = %Comment{ id: 11, path: [14, 28] }
Comment.make_child_of(comment, parent_comment)
# => Ecto.Changeset<changes: %{ path: [14, 28, 11] }, ...>
```

## Fetching functions

#### `parent/1`

Returns an `Ecto.Query` to find parent for a node

```
comment = %Comment{ path: [14, 17, 18] }
Comment.parent(comment) # => Ecto.Query to find node with id == 18

root_comment = %Comment{ path: [] }
Comment.root(root_comment) # => Ecto.Query which will return nothing
```

#### `parent_id/1`

Returns a parent node id. It'll return nil for root node

```
comment = %Comment{ path: [14, 17, 18] }
Comment.parent_id(comment) # => 18

root_comment = %Comment{ path: [] }
Comment.root(root_comment) # => nil
```

#### `root/1`

Takes a node as an argument and returns `Ecto.Query` to find its root - even if node is a root itself :(

``` elixir
comment = %Comment{ path: [15, 16, 17] }
Comment.root(comment) # => Ecto.Query for id=15

root_comment = %Comment{ path: [] }
Comment.root(root_comment) # => Ecto.Query to find self
```

#### `root_id/1`

Returns the node's root id. For the root node, it shows own id.

``` elixir
comment = %Comment{ path: [15, 16, 17] }
Comment.root(comment) # => 15

root_comment = %Comment{ id: 2, path: [] }
Comment.root(root_comment) # => 2
```

#### `root?/1`

Returns true if node is a root, false otherwise

``` elixir
comment = %Comment{ path: [15, 16, 17] }
Comment.root?(comment) # => false

root_comment = %Comment{ id: 2, path: [] }
Comment.root?(root_comment) # => true
```

#### `ancestor_ids/1`

Returns node list of ancestor ids. Function works absolutely the same as `node.path`, but exists for convenience.

``` elixir
comment = %Comment{ path: [15, 16, 17] }
Comment.ancestor_ids(comment) # => [15, 16, 17]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => []
```

#### `ancestors/1`

Returns `Ecto.Query` to find node ancestors.

``` elixir
comment = %Comment{ path: [15, 16, 17] }
Comment.ancestors(comment) # => Ecto.Query to find nodes with ids in [15, 16, 17]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestors(root_comment) # => Ecto.Query which will return nothing
```

#### `path_ids/1`

Returns a list of path ids, starting with the root id and ending with the node's own id.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path_ids(comment) # => [15, 16, 17, 18]

root_comment = %Comment{ id: 2, path: [] }
Comment.path_ids(root_comment) # => [2]
```

#### `path/1`

Returns an `Ecto.Query` which looks for the path ids, starting with the root id and ending with the node's own id.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path(comment) # => Ecto.Query to find nodes with ids: [15, 16, 17, 18]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => Ecto.Query to find nodes with id == 2
```

#### `children/1`

Returns an `Ecto.Query` which searches for the node children.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path(comment) # => Ecto.Query to find nodes with path equals to: [15, 16, 17, 18]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => Ecto.Query to find nodes with path equals to: [2]
```

#### `siblings/1`

Returns an `Ecto.Query` which searches for the node siblings.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path(comment) # => Ecto.Query to find nodes with path: [15, 16, 17]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => Ecto.Query to find nodes with path: []
```

#### `descendants/1`

Returns an `Ecto.Query` which searches for the node descendants.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path(comment) # => Ecto.Query to find nodes with path containing: [15, 16, 17, 18]

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => Ecto.Query to find nodes with path containing: [2]
```

#### `subtree/1`

Returns an `Ecto.Query` which searches for the node & its descendants.

``` elixir
comment = %Comment{ id: 18, path: [15, 16, 17] }
Comment.path(comment) # => Ecto.Query to find node & its descendants

root_comment = %Comment{ id: 2, path: [] }
Comment.ancestor_ids(root_comment) # => Ecto.Query to find node & its descendants
```

#### `depth/1`

You can get depth level of the node in the tree

``` elixir
%Comment{ path: [] } |> Comment.depth() # => 0 for root
%Comment{ path: [15, 47] } |> Comment.depth() # => 2
```

#### `where_depth/2`

You can specify a query to search for nodes with some level of depth. It uses `CARDINALITY()` postgres function internally, so ensure your postgres version is at least `9.4`.

``` elixir
Comment.where_depth(Comment, is_bigger_than: 2) # => Find all nodes with more than 2 levels deep
Comment.where_depth(Comment, is_equal_to: 0) # => Roots only
# is_bigger_than_or_equal_to
# is_smaller_than_or_equal_to
# is_smaller_than

# You can pass query instead of schema, like:
query = Ecto.Query.from(q in Comment, ...)
query |> Comment.where_depth(is_equal_to: 1)
```

## Arrangement

You can build a tree from the flat list of nested objects by using `arrange/1`. This function will return a tree of nested nodes which are looking like `{ object, list_of_children_tuples_like_me }`. For example:

``` elixir
comment_1 = %Comment{ id: 1 }
  comment_3 = %Comment{ id: 3, path: [1] }
    comment_8 = %Comment{ id: 8, path: [1, 3] }
      comment_9 = %Comment{ id: 9, path: [1, 3, 8] }
  comment_4 = %Comment{ id: 4, path: [1] }
  comment_5 = %Comment{ id: 5, path: [1] }
comment_2 = %Comment{ id: 2 }
  comment_6 = %Comment{ id: 6, path: [2] }
    comment_7 = %Comment{ id: 7, path: [2, 6] }

list = [comment_1, comment_2, comment_3, comment_4, comment_5, comment_6, comment_7, comment_8, comment_9]
Comment.arrange(list)
# =>
# [
#   {comment_1, [
#     {comment_3, [
#       {comment_8, [
#         {comment_9, []}
#       ]}
#     ]},
#     {comment_4, []},
#     {comment_5, []}
#   ]},
#   {comment_2, [
#     {comment_6, [
#       {comment_7, []}
#     ]}
#   ]}
# ]
```

`arrange/1`:
* Saves the order of nodes
* Raises exception if it doesn't arrange all nodes from tree to the list.

## Namespace

You can namespace all your functions on a module, it's very suitable when schema belongs to a couple of trees or in case of function name conflicts. Just do:

``` elixir
use EctoMaterializedPath,
  namespace: "brutalist"
```

And you will have all functions namespaced:

``` elixir
Comment.brutalist_root(comment)
Comment.brutalist_root?(comment)
# et.c.
```

## About [Brutalist](https://brutalist.press)

<a href="https://brutalist.press">
  <img src="https://github.com/asiniy/ecto_materialized_path/blob/master/brutalist_logo.png"
  width="400"
  height="106"
  alt="Brutalist">
</a>
<br /><br />

`ecto_materialized_path` package is maintained and funded by folks from [Brutalist](https://brutalist.press) - media platform for writing and sharing news and stories with strong focus on traditional values, think-tank level analytics and political research.
