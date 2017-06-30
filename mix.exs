defmodule EctoMaterializedPath.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_materialized_path,
      version: "0.1.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
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
end
