defmodule EctoMaterializedPathTest do
  use ExUnit.Case

  defmodule Comment do
    use Ecto.Schema

    use EctoMaterializedPath,
      column_name: "path",
      cache_depth: false

    schema "comments" do
      field :path, EctoMaterializedPath.Path
    end
  end

  describe "root" do
    test "should return self Ecto.Query if it's root itself" do
      root_comment = %Comment{ id: 5, path: nil }
      query = Comment.path_root(root_comment)

      assert get_where_params(query) == [{5, {0, :id}}]
      assert query.limit.expr == 1
    end

    test "should return root Ecto.Query if it's not a root" do
      comment = %Comment{ id: 61, path: "7/81/49" }
      query = Comment.path_root(comment)

      assert get_where_params(query) == [{7, {0, :id}}]
      assert query.limit.expr == 1
    end
  end

  describe "root?" do
    test "should return true if it's root itself" do
      root_comment = %Comment{ id: 5, path: nil }
      assert Comment.path_root?(root_comment) == true
    end

    test "should return false if it's not a root" do
      comment = %Comment{ id: 61, path: "7/81/49" }
      assert Comment.path_root?(comment) == false
    end
  end

  describe "siblings" do
    test "sss" do
      raise "sss"
    end
  end

  describe "ancestors" do
    test "returns empty list for root" do
      root_comment = %Comment{ id: 5, path: nil }
      query = Comment.path_ancestors(comment)
      #

    end

    test "returns empty l"
  end

  describe "ancestor_ids" do
    test "returns empty list for root" do
      root_comment = %Comment{ id: 5, path: nil }
      assert Comment.path_ancestor_ids(root_comment) == []
    end

    test "should return ancestor ids" do
      comment = %Comment{ id: 61, path: "7/81/49" }
      assert Comment.path_ancestor_ids(comment) == [7, 81, 49]
    end
  end

  defp get_where_params(query) do
    %{wheres: [where]} = query
    where.params
  end
end
