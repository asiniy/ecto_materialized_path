defmodule EctoMaterializedPath.PathTest do
  use ExUnit.Case, async: true

  alias EctoMaterializedPath.Path

  test "passes with empty array" do
    assert Path.cast([]) == { :ok, [] }
  end

  test "passes with correct path" do
    assert Path.cast([13, 45, 18]) == { :ok, [13, 45, 18] }
  end

  test "passes with UUID's" do
    assert Path.cast(["38432046-4351-4676-8988-10f0262da113", "a65ce828-52f2-4931-8719-9f7d97723f3b"]) == { :ok, ["38432046-4351-4676-8988-10f0262da113", "a65ce828-52f2-4931-8719-9f7d97723f3b"] }
  end

  test "fails with random value" do
    assert Path.cast(4) == :error
  end

  test "fails with wrongs path" do
    assert Path.cast([14, [:ok], 45]) == :error
  end
end
