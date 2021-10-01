defmodule EctoMaterializedPath.Adapters.MyXQL do
  import Ecto.Query

  def array_equal(field, value) do
    dynamic([q], fragment("CAST(? as JSON) = CAST(? as JSON)", field(q, ^field), ^value))
  end

  def array_contains(field, value) do
    dynamic(
      [q],
      fragment("JSON_CONTAINS(CAST(? as JSON), CAST(? as JSON)) = 1", field(q, ^field), ^value)
    )
  end

  def array_length_bigger_than(field, value) do
    dynamic([q], fragment("JSON_LENGTH(CAST(? as JSON)) > ?", field(q, ^field), ^value))
  end

  def array_length_bigger_than_or_equal_to(field, value) do
    dynamic([q], fragment("JSON_LENGTH(CAST(? as JSON)) >= ?", field(q, ^field), ^value))
  end

  def array_length_equal_to(field, value) do
    dynamic([q], fragment("JSON_LENGTH(CAST(? as JSON)) = ?", field(q, ^field), ^value))
  end

  def array_length_smaller_than_or_equal_to(field, value) do
    dynamic([q], fragment("JSON_LENGTH(CAST(? as JSON)) <= ?", field(q, ^field), ^value))
  end

  def array_length_smaller_than(field, value) do
    dynamic([q], fragment("JSON_LENGTH(CAST(? as JSON)) < ?", field(q, ^field), ^value))
  end
end
