defmodule EctoMaterializedPath do
  defmacro __using__(opts) do
    column_name = Keyword.get(opts, :column_name, :path)
    adapter = Keyword.fetch!(opts, :adapter)

    quote bind_quoted: [
            column_name: column_name,
            adapter: adapter
          ] do
      import Ecto.Query

      def parent(struct = %{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path}) do
        parent_id = parent_id(struct)

        if parent_id == nil do
          from q in __MODULE__, where: is_nil(q.id), limit: 1
        else
          from q in __MODULE__, where: q.id == ^parent_id, limit: 1
        end
      end

      def parent_id(%{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path}) do
        List.last(path)
      end

      def root(struct = %{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path) do
        root_id = root_id(struct)
        from q in __MODULE__, where: q.id == ^root_id, limit: 1
      end

      def root_id(%{:__struct__ => __MODULE__, :id => id, unquote(:"#{column_name}") => []})
          when is_integer(id),
          do: id

      def root_id(%{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path),
          do: List.first(path)

      def root?(%{:__struct__ => __MODULE__, :id => id, unquote(:"#{column_name}") => []})
          when is_integer(id),
          do: true

      def root?(%{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path),
          do: false

      def ancestors(struct = %{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path) do
        from q in __MODULE__, where: q.id in ^ancestor_ids(struct)
      end

      def ancestor_ids(%{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path),
          do: path

      def path(struct = %{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path}) do
        path_ids = path_ids(struct)
        from q in __MODULE__, where: q.id in ^path_ids
      end

      def path_ids(
            struct = %{:__struct__ => __MODULE__, :id => id, unquote(:"#{column_name}") => path}
          ),
          do: ancestor_ids(struct) ++ [id]

      def depth(%{:__struct__ => __MODULE__, unquote(:"#{column_name}") => path})
          when is_list(path),
          do: length(path)

      def children(struct = %{__struct__: __MODULE__, id: id}) do
        path = Map.get(struct, unquote(:"#{column_name}")) ++ [id]

        from q in __MODULE__,
          where: ^unquote(adapter).array_equal(unquote(:"#{column_name}"), path)
      end

      def siblings(struct = %{__struct__: __MODULE__}) do
        path = Map.get(struct, unquote(:"#{column_name}"))

        from q in __MODULE__,
          where: ^unquote(adapter).array_equal(unquote(:"#{column_name}"), path)
      end

      def descendants(struct = %{__struct__: __MODULE__, id: id}) do
        path = Map.get(struct, unquote(:"#{column_name}")) ++ [id]

        from q in __MODULE__,
          where: ^unquote(adapter).array_contains(unquote(:"#{column_name}"), path)
      end

      def subtree(struct = %{__struct__: __MODULE__, id: id}) do
        path = Map.get(struct, unquote(:"#{column_name}")) ++ [id]

        from q in __MODULE__,
          where: ^unquote(adapter).array_contains(unquote(:"#{column_name}"), path),
          or_where: q.id == ^id
      end

      def where_depth(
            query = %Ecto.Query{from: %Ecto.Query.FromExpr{source: {_source, __MODULE__}}},
            depth_options
          ) do
        do_where_depth(query, depth_options)
      end

      def where_depth(__MODULE__, depth_options) do
        query = from(q in __MODULE__)
        do_where_depth(query, depth_options)
      end

      defp do_where_depth(query, is_bigger_than: depth)
           when is_integer(depth) and depth >= 0 do
        from q in query,
          where: ^unquote(adapter).array_length_bigger_than(unquote(:"#{column_name}"), depth)
      end

      defp do_where_depth(query, is_bigger_than_or_equal_to: depth)
           when is_integer(depth) and depth >= 0 do
        from q in query,
          where:
            ^unquote(adapter).array_length_bigger_than_or_equal_to(
              unquote(:"#{column_name}"),
              depth
            )
      end

      defp do_where_depth(query, is_equal_to: depth)
           when is_integer(depth) and depth >= 0 do
        from q in query,
          where: ^unquote(adapter).array_length_equal_to(unquote(:"#{column_name}"), depth)
      end

      defp do_where_depth(query, is_smaller_than_or_equal_to: depth)
           when is_integer(depth) and depth >= 0 do
        from q in query,
          where:
            ^unquote(adapter).array_length_smaller_than_or_equal_to(
              unquote(:"#{column_name}"),
              depth
            )
      end

      defp do_where_depth(query, is_smaller_than: depth)
           when is_integer(depth) and depth > 0 do
        from q in query,
          where: ^unquote(adapter).array_length_smaller_than(unquote(:"#{column_name}"), depth)
      end

      defp do_where_depth(_, _) do
        raise ArgumentError, "invalid arguments"
      end

      def build_child(parent = %{__struct__: __MODULE__, id: id})
          when is_integer(id) and is_atom(unquote(:"#{column_name}")) do
        new_path = Map.get(parent, unquote(:"#{column_name}")) ++ [id]

        __MODULE__
        |> Kernel.struct()
        |> Map.put(unquote(:"#{column_name}"), new_path)
      end

      def make_child_of(
            changeset = %Ecto.Changeset{data: %{__struct__: __MODULE__}},
            parent = %{__struct__: __MODULE__, id: id}
          ) do
        new_path = Map.get(parent, unquote(:"#{column_name}")) ++ [id]
        Ecto.Changeset.change(changeset, %{unquote(:"#{column_name}") => new_path})
      end

      def make_child_of(
            struct = %{__struct__: __MODULE__},
            parent = %{__struct__: __MODULE__}
          ) do
        struct
        |> Ecto.Changeset.change()
        |> make_child_of(parent)
      end

      def arrange([]), do: []

      def arrange(nodes_list) when is_list(nodes_list) do
        nodes_depth_map = nodes_by_depth_map(nodes_list, %{})

        initial_depth_level = nodes_depth_map |> Map.keys() |> Enum.min()
        initial_list = Map.get(nodes_depth_map, initial_depth_level)
        initial_nodes_depth_map = Map.delete(nodes_depth_map, initial_depth_level)

        {tree, tree_nodes_count} =
          Enum.reduce(
            initial_list,
            {[], length(initial_list)},
            &extract_to_resulting_structure(
              &1,
              &2,
              initial_nodes_depth_map,
              initial_depth_level
            )
          )

        check_nodes_arrangement_correctness(tree, tree_nodes_count, nodes_list)

        tree
      end

      defp nodes_by_depth_map([], processed_map), do: processed_map

      defp nodes_by_depth_map([node | tail], before_node_processed_map) do
        path = Map.get(node, unquote(:"#{column_name}"))
        node_depth = depth(node)

        node_at_depth = Map.get(before_node_processed_map, node_depth, []) ++ [node]
        after_node_processed_map = Map.put(before_node_processed_map, node_depth, node_at_depth)

        nodes_by_depth_map(tail, after_node_processed_map)
      end

      defp extract_to_resulting_structure(
             node,
             {list, total_count},
             nodes_depth_map,
             depth_level
           ) do
        next_depth_level = depth_level + 1

        {node_children, node_children_count} =
          nodes_depth_map
          |> Map.get(next_depth_level, [])
          |> Enum.filter(fn possible_children ->
            Map.get(possible_children, unquote(:"#{column_name}")) |> List.last() == node.id
          end)
          |> Enum.reduce(
            {[], total_count},
            &extract_to_resulting_structure(
              &1,
              &2,
              nodes_depth_map,
              next_depth_level
            )
          )

        {list ++ [{node, node_children}], length(node_children) + node_children_count}
      end

      defp check_nodes_arrangement_correctness(tree, tree_nodes_count, nodes_list) do
        nodes_count = length(nodes_list)

        if tree_nodes_count != nodes_count do
          nodes_list_ids = nodes_list |> Enum.map(&Map.get(&1, :id))

          tree_node_ids =
            Enum.map(tree, fn element -> get_node_ids_from_tree(element) end) |> List.flatten()

          missing_node_ids = nodes_list_ids -- tree_node_ids

          raise ArgumentError,
                "nodes with ids [#{Enum.join(missing_node_ids, ", ")}] can't be arranged"
        end
      end

      defp get_node_ids_from_tree({node, []}), do: [node.id]

      defp get_node_ids_from_tree({node, list}) do
        [node.id, Enum.map(list, &get_node_ids_from_tree(&1))]
      end
    end
  end
end
