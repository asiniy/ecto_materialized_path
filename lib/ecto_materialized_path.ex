defmodule EctoMaterializedPath do
  defmacro __using__(opts) do
    column_name = Keyword.get(opts, :column_name, "path")
    cache_depth = Keyword.get(opts, :cache_depth, false)
    namespace = Keyword.get(opts, :namespace, nil)
    method_namespace = if is_nil(namespace), do: nil, else: "#{namespace}_"

    quote bind_quoted: [
      column_name: column_name,
      cache_depth: cache_depth,
      method_namespace: method_namespace,
    ] do

      ~w(
        root
        root?
        root_id
        ancestors
        ancestor_ids
      ) |> Enum.each(fn(function_name) ->
        def unquote(:"#{method_namespace}#{function_name}")(schema = %{ __struct__: __MODULE__ }) do
          path = Map.get(schema, unquote(:"#{column_name}"))
          apply(EctoMaterializedPath, unquote(:"#{function_name}"), [schema, path])
        end
      end)

      def unquote(:"#{method_namespace}build_child")(schema = %{ __struct__: __MODULE__ }) do
        EctoMaterializedPath.build_child(schema, unquote(:"#{column_name}"))
      end

      # def unquote(:"#{method_namespace}arrange")(schemas_list) when is_list(schemas), do: EctoMaterializedPath.arrange(list)

    end
  end

  require Ecto.Query

  def root(schema = %{ __struct__: struct }, path) when is_list(path) do
    root_id = root_id(schema, path)
    Ecto.Query.from(q in struct, where: q.id == ^root_id, limit: 1)
  end

  def root_id(%{ id: id }, []) when is_integer(id), do: id
  def root_id(_, path) when is_list(path), do: path |> List.first()

  def root?(%{ id: id }, []) when is_integer(id), do: true
  def root?(_, path) when is_list(path), do: false

  def ancestors(schema = %{ __struct__: struct }, path) when is_list(path) do
    Ecto.Query.from(q in struct, where: q.id in ^ancestor_ids(schema, path))
  end

  def ancestor_ids(_, path) when is_list(path), do: path

  def build_child(schema = %{ __struct__: struct, id: id }, column_name) when is_integer(id) and is_atom(column_name) do
    new_path = Map.get(schema, column_name) ++ [id]

    %{ __struct__: struct } |> Map.put(column_name, new_path)
  end

  def arrange(list) do
    #ordered_list = []

    # list.each do |node|
    #   ordered_list.find_index(id: node.parent_id)

    # Find minimal depth
    # do_arrange(list, [], minimal_depth)
  end

  defp do_arrange(list, tree, depth) do
    # find_all_schemas_with_depth
    # create new tree
    # do_arrange(list - find_all_schemas_with_minimal_depth, new_tree, depth + 1)
  end

  defp do_arrange([], tree, _), do: tree
end


# use EctoMaterializedPath,
#   column_name: "path", # default: "path"
#
# defmodule Comment do
#   schema "comments" do
#     field :body, :string
#     field :path, EctoMaterializePath.Path # => nil, not contains / and integer
#   end
# end
