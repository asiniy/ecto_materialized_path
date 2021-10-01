defmodule EctoMaterializedPath.Adapters.Postgres do
  import Ecto.Query

  def array_equal(field, value) do
    dynamic([q], fragment("? = ?", field(q, ^field), ^value))
  end

  def array_contains(field, value) do
    dynamic([q], fragment("? @> ?", field(q, ^field), ^value))
  end

  def array_length_bigger_than(field, value) do
    dynamic([q], fragment("CARDINALITY(?) > ?", field(q, ^field), ^value))
  end

  def array_length_bigger_than_or_equal_to(field, value) do
    dynamic([q], fragment("CARDINALITY(?) >= ?", field(q, ^field), ^value))
  end

  def array_length_equal_to(field, value) do
    dynamic([q], fragment("CARDINALITY(?) = ?", field(q, ^field), ^value))
  end

  def array_length_smaller_than_or_equal_to(field, value) do
    dynamic([q], fragment("CARDINALITY(?) <= ?", field(q, ^field), ^value))
  end

  def array_length_smaller_than(field, value) do
    dynamic([q], fragment("CARDINALITY(?) < ?", field(q, ^field), ^value))
  end
end
