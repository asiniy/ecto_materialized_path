defmodule EctoMaterializedPathTest do
  use ExUnit.Case

  defmodule Comment do
    use Ecto.Schema

    use EctoMaterializedPath,
      column_name: "path",
      cache_depth: false

    schema "comments" do
      field :path, :string # TODO replace it with a EctoMaterializedPath.Path
    end
  end

  describe "root" do
    test "should return self if it's root itself" do
      root_comment = %Comment{ id: 5, path: nil }
      query = Comment.root(root_comment)

      assert get_where_params(query) == [{5, {0, :id}}]
      assert query.limit.expr == 1
    end

    test "should return root Ecto.Query if it's not a root" do
      comment = %Comment{ id: 61, path: "7/81/49" }
      query = Comment.root(comment)

      assert get_where_params(query) == [{7, {0, :id}}]
      assert query.limit.expr == 1
    end
  end

  describe "root?" do
    # Comment.root?(comment)
  end

  describe "siblings" do
    #
  end

  defp get_where_params(query) do
    %{wheres: [where]} = query
    where.params
  end
end
