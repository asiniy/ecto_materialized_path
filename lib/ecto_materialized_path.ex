defmodule EctoMaterializedPath do
  defmacro __using__(opts) do
    column_name = Keyword.get(opts, :column_name, "path")
    cache_depth = Keyword.get(opts, :cache_depth, false)

    quote bind_quoted: [
      column_name: column_name,
      cache_depth: cache_depth
    ] do

      def root(schema), do: EctoMaterializedPath.root(schema) # TODO pattern matching on self module

    end
  end

  require Ecto.Query

  def root(%{ __struct__: struct, id: id, path: nil }) when is_integer(id) do
    Ecto.Query.from(q in struct, where: q.id == ^id, limit: 1)
  end
  def root(%{ __struct__: struct, path: path }) when is_binary(path) do
    root_id = path_ids_list(path) |> List.first()
    Ecto.Query.from(q in struct, where: q.id == ^root_id, limit: 1)
  end

  defp path_ids_list(path) do
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
