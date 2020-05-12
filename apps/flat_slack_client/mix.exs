defmodule FlatSlackClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :flat_slack_client,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :sqlite_ecto2, :ecto],
      mod: {FlatSlackClient, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
   
    [
      {:sqlite_ecto2, "~> 2.2"},
      {:flat_slack_server, in_umbrella: true},
      {:ratatouille, "~> 0.5.0"}
    ]
  end
end
