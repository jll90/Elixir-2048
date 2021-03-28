defmodule Engine2048.MixProject do
  use Mix.Project

  def project do
    [
      app: :engine2048,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Engine2048"
      # source_url: "https://github.com/USER/PROJECT",
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      # docs: [
      #   main: "Engine2048",
      #   logo: "path/to/logo.png",
      #   extras: ["README.md"]
      # ]
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
      # mix.exs
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
