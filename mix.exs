defmodule EctoMaterializedPath.Mixfile do
  use Mix.Project

  @project_url "https://github.com/asiniy/ecto_materialized_path"
  @version "0.2.0"

  def project do
    [
      app: :ecto_materialized_path,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @project_url,
      homepage_url: @project_url,
      description:
        "Tree structure & hierarchy for ecto models. Ancestry, materialized path, nested set, adjacency list",
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths, do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, ">= 3.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, "~> 0.15.0", only: :test},
      {:myxql, "~> 0.5.1", only: :test},
      {:jason, ">= 0.0.0", only: :test}
    ]
  end

  defp package() do
    [
      name: :ecto_materialized_path,
      files: ["lib/**/*.ex", "mix.exs"],
      maintainers: ["Alex Antonov"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @project_url,
        "Author's blog" => "http://asiniy.github.io/"
      }
    ]
  end

  defp aliases() do
    [
      # Ensures database is reset before tests are run
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
