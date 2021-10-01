defmodule EctoMaterializedPath.PathTest do
  use ExUnit.Case, async: true

  alias EctoMaterializedPath.Path

  test "passes with empty array" do
    assert Path.cast([]) == {:ok, []}
  end

  test "passes with correct path" do
    assert Path.cast([13, 45, 18]) == {:ok, [13, 45, 18]}
  end

  test "fails with random value" do
    assert Path.cast(4) == :error
  end

  test "fails with wrongs path" do
    assert Path.cast([14, "ee", 45]) == :error
  end
end
