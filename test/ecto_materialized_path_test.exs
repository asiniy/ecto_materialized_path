defmodule EctoMaterializedPathTest do
  use ExUnit.Case
  require Ecto.Query

  defmodule Comment do
    use Ecto.Schema

    use EctoMaterializedPath,
      column_name: "path"

    schema "comments" do
      field :path, EctoMaterializedPath.Path, default: []
    end
  end

  describe "parent" do
    test "should return Ecto.Query for nothing for root node" do
      root_comment = %Comment{ id: 5, path: [] }
      query = Comment.parent(root_comment)

      assert get_where_params(query) == [{nil, {:in, {0, :id}}}]
      assert query.limit.expr == 1
    end

    test "should return Ecto.Query for parent if it's a child node" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      query = Comment.parent(comment)

      assert get_where_params(query) == [{49, {:in, {0, :id}}}]
      assert query.limit.expr == 1
    end
  end

  describe "parent_id" do
    test "should return parent id if it's parent itself" do
      root_comment = %Comment{ id: 5, path: [] }
      assert Comment.parent_id(root_comment) |> is_nil()
    end

    test "should return parent id if it's a child" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      assert Comment.parent_id(comment) == 49
    end
  end

  describe "root" do
    test "should return self Ecto.Query if it's root itself" do
      root_comment = %Comment{ id: 5 }
      query = Comment.root(root_comment)

      assert get_where_params(query) == [{5, {:in, {0, :id}}}]
      assert query.limit.expr == 1
    end

    test "should return root Ecto.Query if it's not a root" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      query = Comment.root(comment)

      assert get_where_params(query) == [{7, {:in, {0, :id}}}]
      assert query.limit.expr == 1
    end
  end

  describe "root_id" do
    test "should return root id if it's root itself" do
      root_comment = %Comment{ id: 5, path: [] }
      assert Comment.root_id(root_comment) == 5
    end

    test "should return root id if it's a child" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      assert Comment.root_id(comment) == 7
    end
  end

  describe "root?" do
    test "should return true if it's root itself" do
      root_comment = %Comment{ id: 5, path: [] }
      assert Comment.root?(root_comment) == true
    end

    test "should return false if it's not a root" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      assert Comment.root?(comment) == false
    end
  end

  describe "ancestors" do
    test "returns empty Ecto.Query for root" do
      root_comment = %Comment{ id: 5, path: [] }
      query = Comment.ancestors(root_comment)

      assert get_where_params(query) == [{[], {:in, {0, :id}}}]
    end

    test "returns Ecto.Query with ancestor_ids" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      query = Comment.ancestors(comment)

      assert get_where_params(query) == [{[7, 81, 49], {:in, {0, :id}}}]
    end
  end

  describe "ancestor_ids" do
    test "returns empty list for root" do
      root_comment = %Comment{ id: 5, path: [] }
      assert Comment.ancestor_ids(root_comment) == []
    end

    test "should return ancestor ids" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      assert Comment.ancestor_ids(comment) == [7, 81, 49]
    end
  end

  describe "path_ids" do
    test "returns empty self id for root" do
      root_comment = %Comment{ id: 5, path: [] }
      assert Comment.path_ids(root_comment) == [5]
    end

    test "should return ancestor ids + self id" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      assert Comment.path_ids(comment) == [7, 81, 49, 61]
    end
  end

  describe "path" do
    test "returns Ecto.Query to search for itself for root" do
      root_comment = %Comment{ id: 5, path: [] }
      query = Comment.path(root_comment)

      assert get_where_params(query) == [{ [5], {:in, {0, :id}}}]
    end

    test "should Ecto.Query to search for ancestors & self for child node" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      query = Comment.path(comment)

      assert get_where_params(query) == [{ [7, 81, 49, 61], {:in, {0, :id}}}]
    end
  end

  describe "children" do
    test "returns Ecto.Query to search for a root children" do
      root_comment = %Comment{ id: 5, path: [] }
      Comment.children(root_comment)

      # how to test it?
    end

    test "should Ecto.Query to search for node children" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      Comment.children(comment)

      # how to test it
    end
  end

  describe "siblings" do
    test "returns Ecto.Query to search for root siblings" do
      root_comment = %Comment{ id: 5, path: [] }
      Comment.siblings(root_comment)

      # how to test it?
    end

    test "returns Ecto.Query to search for a node siblings" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      Comment.siblings(comment)

      # how to test it
    end
  end

  describe "descendants" do
    test "returns Ecto.Query to search for root siblings" do
      root_comment = %Comment{ id: 5, path: [] }
      Comment.descendants(root_comment)

      # how to test it?
    end

    test "returns Ecto.Query to search for a node siblings" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      Comment.descendants(comment)

      # how to test it
    end
  end

  describe "subtree" do
    test "returns Ecto.Query to search for root & its descendants" do
      root_comment = %Comment{ id: 5, path: [] }
      Comment.subtree(root_comment)

      # how to test it?
    end

    test "returns Ecto.Query to search for a node & its descendants" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      Comment.subtree(comment)

      # how to test it
    end
  end

  describe "depth" do
    test "root depth is equal to 0" do
      root_comment = %Comment{ id: 17, path: [] }
      assert Comment.depth(root_comment) == 0
    end

    test "counts depth correctly" do
      comment = %Comment{ id: 11, path: [10, 28, 41] }
      assert Comment.depth(comment) == 3
    end
  end

  describe "where_depth" do
    test "takes only one argument" do
      assert_raise ArgumentError, "invalid arguments", fn() ->
        Comment.where_depth(Comment, is_equal_to: 5, is_bigger_than: 4)
      end
    end

    test "is_bigger_than" do
      query = Comment.where_depth(Comment, is_bigger_than: 3)

      assert query.__struct__ == Ecto.Query
      # how test it?
    end

    test "is_bigger_than_or_equal_to" do
      query = Comment.where_depth(Comment, is_bigger_than_or_equal_to: 3)

      assert query.__struct__ == Ecto.Query
      # how to test it?
    end

    test "is_equal_to" do
      query = Comment.where_depth(Comment, is_equal_to: 3)

      assert query.__struct__ == Ecto.Query
      # how to test it?
    end

    test "is_smaller_than_or_equal_to" do
      query = Comment.where_depth(Comment, is_smaller_than_or_equal_to: 3)

      assert query.__struct__ == Ecto.Query
      # how to test it?
    end

    test "is_smaller_than" do
      query = Comment.where_depth(Comment, is_smaller_than: 3)

      assert query.__struct__ == Ecto.Query
      # hot to test it?
    end

    test "combines with other queries" do
      query = Comment |> Ecto.Query.where(id: [17, 18, 19]) |> Comment.where_depth(is_equal_to: 4)

      assert query.__struct__ == Ecto.Query
    end
  end

  describe "build_child" do
    test "returns child with parent path as root" do
      root_comment = %Comment{ id: 7, path: [] }
      child = Comment.build_child(root_comment)

      assert child.__struct__ == Comment
      assert child.path == [7]
    end

    test "returns child with parent path if not a root" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      child = Comment.build_child(comment)

      assert child.__struct__ == Comment
      assert child.path == [7, 81, 49, 61]
    end
  end

  describe "make_child_of" do
    test "returns changeset for a root comment" do
      parent_comment = %Comment{ id: 7, path: [] }
      comment = %Comment{ id: nil }

      changeset = Comment.make_child_of(comment, parent_comment)
      assert changeset.changes == %{ path: [7] }
    end

    test "returns changeset for a root comment changeset" do
      parent_comment = %Comment{ id: 7, path: [] }
      comment = %Comment{ id: nil } |> Ecto.Changeset.change(%{})

      changeset = Comment.make_child_of(comment, parent_comment)
      assert changeset.changes == %{ path: [7] }
    end

    test "returns changeset for a child comment" do
      parent_comment = %Comment{ id: 7, path: [16, 18, 49] }
      comment = %Comment{ id: 61, path: [] }

      changeset = Comment.make_child_of(comment, parent_comment)
      assert changeset.changes == %{ path: [16, 18, 49, 7] }
    end

    test "returns changeset for a child comment changeset" do
      parent_comment = %Comment{ id: 7, path: [16, 18, 49] }
      comment = %Comment{ id: 61, path: [] } |> Ecto.Changeset.change(%{})

      changeset = Comment.make_child_of(comment, parent_comment)
      assert changeset.changes == %{ path: [16, 18, 49, 7] }
    end
  end

  describe "arrange" do
    test "arranges well" do
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
      tree = Comment.arrange(list)

      assert tree == [
        {comment_1, [
          {comment_3, [
            {comment_8, [
              {comment_9, []}
            ]}
          ]},
          {comment_4, []},
          {comment_5, []}
        ]},
        {comment_2, [
          {comment_6, [
            {comment_7, []}
          ]}
        ]}
      ]
    end

    test "arranges non-root nodes as well" do
      comment_10 = %Comment{ id: 10, path: [13, 15, 18] }
        comment_11 = %Comment{ id: 11, path: [13, 15, 18, 10] }
      comment_12 = %Comment{ id: 12, path: [14, 19, 45] }

      list = [comment_11, comment_10, comment_12]
      tree = Comment.arrange(list)

      assert tree == [
        {comment_10, [
          { comment_11, [] }
        ]},
        { comment_12, [] }
      ]
    end

    test "returns empty list if there are no children" do
      assert Comment.arrange([]) == []
    end

    test "raises an exception when node can't arranged" do
      comment_1 = %Comment{ id: 1 }
        comment_3 = %Comment{ id: 3, path: [1] }
      # parent is missing
        comment_2 = %Comment{ id: 2, path: [4]}

      list = [comment_1, comment_2, comment_3]

      assert_raise ArgumentError, "nodes with ids [2] can't be arranged", fn ->
        Comment.arrange(list)
      end
    end
  end

  describe "column_name" do
    defmodule AnotherComment do
      use Ecto.Schema

      use EctoMaterializedPath,
        column_name: "another"

      schema "another_comments" do
        field :another, EctoMaterializedPath.Path
      end
    end

    test "it uses column name properly" do
      comment = %AnotherComment{ another: [15, 41, 22] }
      assert AnotherComment.ancestor_ids(comment) == [15, 41, 22]
    end
  end

  describe "namespace" do
    defmodule NamespacedComment do
      use Ecto.Schema

      use EctoMaterializedPath,
        namespace: "alex"

      schema "namespaced_comments" do
        field :path, EctoMaterializedPath.Path
      end
    end

    test "should return self Ecto.Query if it's root itself" do
      root_comment = %NamespacedComment{ id: 5, path: [] }
      query = NamespacedComment.alex_root(root_comment)

      assert get_where_params(query) == [{5, {:in, {0, :id}}}]
      assert query.limit.expr == 1
    end
  end

  defp get_where_params(query) do
    %{wheres: [where]} = query
    where.params
  end
end
