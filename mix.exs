defmodule EctoMaterializedPath.Mixfile do
  use Mix.Project

  @project_url "https://github.com/asiniy/ecto_materialized_path"
  @version "0.1.0"

  def project do
    [
      app: :ecto_materialized_path,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @project_url,
      homepage_url: @project_url,
      description: "Tree structure & hierarchy for ecto models. Ancestry, materialized path, nested set, adjacency list",
      package: package(),
      deps: deps()
    ]
  end


  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support", "test/dummy"]
  defp elixirc_paths(_),     do: elixirc_paths()
  defp elixirc_paths,        do: ["lib"]

  def application do
    [
      applications: app_list(Mix.env),
    ]
  end

  def app_list(:test), do: app_list() ++ [:ecto, :ex_machina]
  def app_list(_), do: app_list()
  def app_list, do: [:logger]

  defp deps do
    [
     {:ecto, ">= 2.0.0"},

     {:ex_machina, "~> 1.0.0", only: :test},

     {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package() do
    [
      name: :ecto_materialized_path,
      files: ["lib/**/*.ex", "mix.exs"],
      maintainers: ["Alex Antonov"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub"        => @project_url,
        "Author's blog" => "http://asiniy.github.io/"
      }
    ]
  end
end
