# Ecto materialized path

* All basic functions
* Arrange
* Circle CI
* Version
* Document me
* Publish
* PR

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_materialized_path` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ecto_materialized_path, "~> 0.1.0"}]
end
```

## Assigning functions

Are usable when you need to assign some schema as a child of another schema

#### build_child/1

``` elixir
comment = %Comment{ id: 17, path: [89] }
Comment.build_child(comment)
# => %Comment{ id: nil, path: [17, 89] }
```

#### make_child_of/2

Takes a struct (or changeset) and parent struct; returns changeset with correct path.

``` elixir
comment = %Comment{ id: 17, path: [] } # or comment |> Ecto.Changeset.change(%{})
parent_comment = %Comment{ id: 11, path: [14, 28] }
Comment.make_child_of(comment, parent_comment)
# => Ecto.Changeset<changes: %{ path: [14, 28, 11] }, ...>
```

## Fetching functions

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

#### depth/1

You can get depth level of the node in the tree

``` elixir
%Comment{ path: [] } |> Comment.depth() # => 0 for root
%Comment{ path: [15, 47] } |> Comment.depth() # => 2
```

### where_depth/2

You can specify a query to search for nodes with some level of depth

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
* Raises exception if it wouldn't arrange all nodes from tree to the list.

## Namespace

You can namespace all your functions on a module, it's very suitable when schema belongs to a couple of trees or in the case of function name conflicts. Just do:

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
