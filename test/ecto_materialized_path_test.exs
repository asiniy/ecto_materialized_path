defmodule EctoMaterializedPathTest do
  use ExUnit.Case

  defmodule Comment do
    use Ecto.Schema

    use EctoMaterializedPath,
      column_name: "path"

    schema "comments" do
      field :path, EctoMaterializedPath.Path
    end
  end

  describe "root" do
    test "should return self Ecto.Query if it's root itself" do
      root_comment = %Comment{ id: 5, path: [] }
      query = Comment.root(root_comment)

      assert get_where_params(query) == [{5, {0, :id}}]
      assert query.limit.expr == 1
    end

    test "should return root Ecto.Query if it's not a root" do
      comment = %Comment{ id: 61, path: [7, 81, 49] }
      query = Comment.root(comment)

      assert get_where_params(query) == [{7, {0, :id}}]
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

  describe "siblings" do
    test "sss" do
      raise "sss"
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

      assert get_where_params(query) == [{5, {0, :id}}]
      assert query.limit.expr == 1
    end
  end

  defp get_where_params(query) do
    %{wheres: [where]} = query
    where.params
  end
end
