defmodule EctoMaterializedPath.PathTest do
  use ExUnit.Case, async: true

  alias EctoMaterializedPath.Path

  test "passes with nil" do
    assert Path.cast(nil) == { :ok, nil }
  end

  test "passes with correct path" do
    assert Path.cast("13/45/18") == { :ok, "13/45/18" }
  end

  test "fails with random value" do
    assert Path.cast(4) == :error
  end

  test "fails with path containing 2 consequent slashes" do
    assert Path.cast("14//41") == :error
  end

  test "fails with wrongs path" do
    assert Path.cast("14/abc/81") == :error
  end
end
