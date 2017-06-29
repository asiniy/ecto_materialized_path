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
          apply(EctoMaterializedPath, unquote(:"#{function_name}"), [schema])
        end
      end)

      # def unquote(:"#{method_namespace}arrange")(schemas_list) when is_list(schemas), do: EctoMaterializedPath.arrange(list)

    end
  end

  require Ecto.Query

  def root(schema = %{ __struct__: struct, path: path }) when is_list(path) do
    root_id = root_id(schema)
    Ecto.Query.from(q in struct, where: q.id == ^root_id, limit: 1)
  end

  def root_id(%{ id: id, path: [] }) when is_integer(id), do: id
  def root_id(%{ path: path }) when is_list(path), do: path |> List.first()

  def root?(%{ id: id, path: [] }) when is_integer(id), do: true
  def root?(%{ path: path }) when is_list(path), do: false

  def ancestors(schema = %{ __struct__: struct, path: path }) when is_list(path) do
    Ecto.Query.from(q in struct, where: q.id in ^ancestor_ids(schema))
  end

  def ancestor_ids(%{ path: path }) when is_list(path), do: path
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
