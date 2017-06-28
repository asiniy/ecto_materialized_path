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

      def unquote(:"#{method_namespace}root")(schema = %{ __struct__: __MODULE__ }), do: EctoMaterializedPath.root(schema)
      def unquote(:"#{method_namespace}root?")(schema = %{ __struct__: __MODULE__ }), do: EctoMaterializedPath.root?(schema)

      def unquote(:"#{method_namespace}ancestor_ids")(schema = %{ __struct__: __MODULE__ }), do: EctoMaterializedPath.ancestor_ids(schema)

      # def unquote(:"#{column_name}_arrange")(schemas_list) when is_list(schemas), do: EctoMaterializedPath.arrange(list)

    end
  end

  require Ecto.Query

  def root(%{ __struct__: struct, id: id, path: nil }) when is_integer(id) do
    Ecto.Query.from(q in struct, where: q.id == ^id, limit: 1)
  end
  def root(%{ __struct__: struct, path: path }) when is_binary(path) do
    root_id = path_ids(path) |> List.first()
    Ecto.Query.from(q in struct, where: q.id == ^root_id, limit: 1)
  end

  def root?(%{ id: id, path: nil }) when is_integer(id), do: true
  def root?(%{ path: path }) when is_binary(path), do: false

  def ancestor_ids(%{ path: nil }), do: []
  def ancestor_ids(%{ path: path }) when is_binary(path) do
    path_ids(path)
  end

  defp path_ids(path) when is_binary(path) do
    path |> String.split("/") |> Enum.map(&String.to_integer(&1))
  end
end


# use EctoMaterializedPath,
#   column_name: "path", # default: "path"
#   cache_depth: true # default: false
#
# defmodule Comment do
#   schema "comments" do
#     field :body, :string
#     field :path, EctoMaterializePath.Path # => nil, not contains / and integer
#   end
# end
