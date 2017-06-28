defmodule EctoMaterializedPath.Path do
  @behaviour Ecto.Type

  def cast(nil), do: { :ok, nil }
  def cast(value) when is_binary(value) do
    path_is_correct? = String.split(value, "/")
      |> Enum.all?(fn(splitted) -> Integer.parse(splitted) != :error end)

    if path_is_correct? do
      { :ok, value }
    else
      :error
    end
  end
  def cast(_), do: :error

  def dump(value), do: value
  def load(value), do: value
  def type, do: EctoMaterializedPath.Path
end
