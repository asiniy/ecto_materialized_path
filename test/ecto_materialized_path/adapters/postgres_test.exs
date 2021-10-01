defmodule DemoApp.PostgresRepoTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  alias DemoApp.PostgresRepo, as: Repo
  alias DemoApp.PostgresNode, as: Node

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end

  setup do
    nodes = [
      Repo.insert!(%Node{id: 1, path: []}),
      Repo.insert!(%Node{id: 2, path: [1]}),
      Repo.insert!(%Node{id: 3, path: [1, 2]}),
      Repo.insert!(%Node{id: 4, path: [1, 2]}),
      Repo.insert!(%Node{id: 5, path: [1, 2, 4]}),
      Repo.insert!(%Node{id: 7, path: [1, 2]}),
      Repo.insert!(%Node{id: 8, path: [1, 2, 7]}),
      Repo.insert!(%Node{id: 9, path: []}),
      Repo.insert!(%Node{id: 10, path: [9]})
    ]

    {:ok, nodes: nodes}
  end

  defp get_node!(id) do
    Repo.get!(Node, id)
  end

  describe "build_child/1" do
    test "should return child with parent's path" do
      root = get_node!(1)
      child = Node.build_child(root)

      assert root == Node.parent(child) |> Repo.one()
    end
  end

  describe "make_child_of/2" do
    test "should return changeset when providing a child changeset" do
      root = get_node!(2)

      child_changeset =
        %Node{}
        |> Ecto.Changeset.change()
        |> Node.make_child_of(root)

      assert %{path: [1, 2]} == child_changeset.changes
    end

    test "should return changeset when providing a child" do
      root = get_node!(2)

      child_changeset =
        %Node{}
        |> Node.make_child_of(root)

      assert %{path: [1, 2]} == child_changeset.changes
    end
  end

  describe "arrange/1" do
    test "arranges the whole tree", %{nodes: nodes} do
      tree = Node.arrange(nodes)

      assert tree == [
               {
                 get_node!(1),
                 [
                   {
                     get_node!(2),
                     [
                       {get_node!(3), []},
                       {get_node!(4),
                        [
                          {get_node!(5), []}
                        ]},
                       {get_node!(7),
                        [
                          {get_node!(8), []}
                        ]}
                     ]
                   }
                 ]
               },
               {
                 get_node!(9),
                 [
                   {
                     get_node!(10),
                     []
                   }
                 ]
               }
             ]
    end

    test "arranges the subtree as well", %{nodes: nodes} do
      nodes = Enum.filter(nodes, fn node -> node.id in [2, 3, 4, 5, 7, 8] end)
      tree = Node.arrange(nodes)

      assert tree == [
               {
                 get_node!(2),
                 [
                   {get_node!(3), []},
                   {get_node!(4),
                    [
                      {get_node!(5), []}
                    ]},
                   {get_node!(7),
                    [
                      {get_node!(8), []}
                    ]}
                 ]
               }
             ]
    end

    test "return empty list if there is no child" do
      assert Node.arrange([]) == []
    end

    test "raises an exception when node can't arranged", %{nodes: nodes} do
      nodes = Enum.reject(nodes, fn node -> node.id == 4 end)

      assert_raise ArgumentError, "nodes with ids [5] can't be arranged", fn ->
        Node.arrange(nodes)
      end
    end
  end

  describe "parent/1" do
    test "should return nil for root node" do
      root = Repo.get!(Node, 1)

      assert nil ==
               root
               |> Node.parent()
               |> Repo.one()
    end

    test "should return parent if it's a child node" do
      parent = Repo.get!(Node, 2)
      child = Repo.get!(Node, 3)

      assert parent ==
               child
               |> Node.parent()
               |> Repo.one()
    end
  end

  describe "parent_id/1" do
    test "should return nil for root node" do
      root = Repo.get!(Node, 1)
      assert nil == Node.parent_id(root)
    end

    test "should return parent id if it's a child node" do
      child = Repo.get!(Node, 2)
      assert 1 == Node.parent_id(child)
    end
  end

  describe "root/1" do
    test "should return itself if it's root node" do
      root = Repo.get!(Node, 1)
      assert root == Node.root(root) |> Repo.one()
    end

    test "should return root node if it's a child node" do
      root = Repo.get!(Node, 1)
      child = Repo.get!(Node, 3)
      assert root == Node.root(child) |> Repo.one()
    end
  end

  describe "root_id/1" do
    test "should return id of itself if it's root node" do
      root = Repo.get!(Node, 1)
      assert 1 == Node.root_id(root)
    end

    test "should return root id if it's a child node" do
      child = Repo.get!(Node, 3)
      assert 1 == Node.root_id(child)
    end
  end

  describe "root?" do
    test "should return true for root node" do
      root = Repo.get!(Node, 1)
      assert true == Node.root?(root)
    end

    test "should return false for child node" do
      child_1 = Repo.get!(Node, 2)
      child_2 = Repo.get!(Node, 3)
      assert false == Node.root?(child_1)
      assert false == Node.root?(child_2)
    end
  end

  describe "ancestors/1" do
    test "returns empty list for root node" do
      root = Repo.get!(Node, 1)
      assert [] == Node.ancestors(root) |> Repo.all()
    end

    test "returns ancestors for child node" do
      child = Repo.get!(Node, 3)

      assert [
               Repo.get!(Node, 1),
               Repo.get!(Node, 2)
             ] == Node.ancestors(child) |> Repo.all()
    end
  end

  describe "ancestor_ids/1" do
    test "returns empty list for root node" do
      root = Repo.get!(Node, 1)
      assert [] == Node.ancestor_ids(root)
    end

    test "should return ancestor ids for child node" do
      child = Repo.get!(Node, 3)
      assert [1, 2] == Node.ancestor_ids(child)
    end
  end

  describe "path/1" do
    test "should return Ecto.Query to search for itself if it's root" do
      root = Repo.get!(Node, 1)
      assert [root] == Node.path(root) |> Repo.all()
    end

    test "should return Ecto.Query to search for ancestors and itself if it's child" do
      child = Repo.get!(Node, 3)

      assert [
               Repo.get!(Node, 1),
               Repo.get!(Node, 2),
               child
             ] == Node.path(child) |> Repo.all()
    end
  end

  describe "path_ids/1" do
    test "returns its own id for root" do
      root = Repo.get!(Node, 1)
      assert [1] == Node.path_ids(root)
    end

    test "should return ancestor ids and its own id for child" do
      child = Repo.get!(Node, 3)
      assert [1, 2, 3] == Node.path_ids(child)
    end
  end

  describe "children/1" do
    test "returns Ecto.Query to search for a root children" do
      root = Repo.get!(Node, 1)

      assert [2] |> Enum.map(&get_node!/1) ==
               Node.children(root) |> Repo.all()
    end

    test "should Ecto.Query to search for node children" do
      child = Repo.get!(Node, 2)

      assert [3, 4, 7] |> Enum.map(&get_node!/1) ==
               Node.children(child) |> Repo.all()
    end
  end

  describe "siblings/1" do
    test "returns Ecto.Query to search for root siblings" do
      root = get_node!(1)

      assert [1, 9] |> Enum.map(&get_node!/1) ==
               Node.siblings(root) |> Repo.all()
    end

    test "returns Ecto.Query to search for a node siblings" do
      child = get_node!(3)

      assert [3, 4, 7] |> Enum.map(&get_node!/1) ==
               Node.siblings(child) |> Repo.all()
    end
  end

  describe "descendants/1" do
    test "returns Ecto.Query to search for root siblings" do
      root = get_node!(1)

      assert [2, 3, 4, 5, 7, 8] |> Enum.map(&get_node!/1) ==
               Node.descendants(root) |> Repo.all()
    end

    test "returns Ecto.Query to search for a node siblings" do
      child = get_node!(2)

      assert [3, 4, 5, 7, 8] |> Enum.map(&get_node!/1) ==
               Node.descendants(child) |> Repo.all()
    end
  end

  describe "subtree/1" do
    test "returns Ecto.Query to search for root & its descendants" do
      root = get_node!(1)

      assert [1, 2, 3, 4, 5, 7, 8] |> Enum.map(&get_node!/1) ==
               Node.subtree(root) |> Repo.all()
    end

    test "returns Ecto.Query to search for a node & its descendants" do
      child = get_node!(2)

      assert [2, 3, 4, 5, 7, 8] |> Enum.map(&get_node!/1) ==
               Node.subtree(child) |> Repo.all()
    end
  end

  describe "depth/1" do
    test "root depth is equal to 0" do
      root = get_node!(1)
      assert 0 == Node.depth(root)

      root = get_node!(9)
      assert 0 == Node.depth(root)
    end

    test "counts depth correctly" do
      child = get_node!(3)
      assert 2 == Node.depth(child)

      child = get_node!(2)
      assert 1 == Node.depth(child)

      child = get_node!(8)
      assert 3 == Node.depth(child)
    end
  end

  describe "where_depth/2" do
    test "takes only one argument" do
      assert_raise ArgumentError, "invalid arguments", fn ->
        Node.where_depth(Node, is_equal_to: 5, is_bigger_than: 4)
      end
    end

    test "is_bigger_than" do
      assert [5, 8] |> Enum.map(&get_node!/1) ==
               Node
               |> Node.where_depth(is_bigger_than: 2)
               |> Repo.all()
    end

    test "is_bigger_than_or_equal_to" do
      assert [3, 4, 5, 7, 8] |> Enum.map(&get_node!/1) ==
               Node
               |> Node.where_depth(is_bigger_than_or_equal_to: 2)
               |> Repo.all()
    end

    test "is_equal_to" do
      assert [3, 4, 7] |> Enum.map(&get_node!/1) ==
               Node
               |> Node.where_depth(is_equal_to: 2)
               |> Repo.all()
    end

    test "is_smaller_than_or_equal_to" do
      assert [1, 2, 3, 4, 7, 9, 10] |> Enum.map(&get_node!/1) ==
               Node
               |> Node.where_depth(is_smaller_than_or_equal_to: 2)
               |> Repo.all()
    end

    test "is_smaller_than" do
      assert [1, 2, 9, 10] |> Enum.map(&get_node!/1) ==
               Node
               |> Node.where_depth(is_smaller_than: 2)
               |> Repo.all()
    end

    test "combines with other queries" do
      assert [8] |> Enum.map(&get_node!/1) ==
               Node
               |> where([n], n.id in [3, 4, 8])
               |> Node.where_depth(is_equal_to: 3)
               |> Repo.all()
    end
  end

  describe "column_name" do
    defmodule AnotherNode do
      use Ecto.Schema

      use EctoMaterializedPath,
        column_name: :way,
        adapter: EctoMaterializedPath.Adapters.Postgres

      schema "another_comments" do
        field :way, EctoMaterializedPath.Path
      end
    end

    test "can be customized manually" do
      node = %AnotherNode{way: [15, 41, 22]}
      assert AnotherNode.ancestor_ids(node) == [15, 41, 22]
    end
  end
end
