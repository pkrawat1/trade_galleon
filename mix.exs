defmodule TradeGalleon.MixProject do
  use Mix.Project

  def project do
    [
      app: :trade_galleon,
      version: "0.1.0",
      elixir: "~> 1.18.1",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        "test.watch": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:tesla, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:websockex, "~> 0.4.3"},
      {:phoenix_pubsub, "~> 2.1"},
      {:ecto, "~> 3.11"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
