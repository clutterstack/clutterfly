defmodule Clutterfly.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/clutterstack/clutterfly"

  def project do
    [
      app: :clutterfly,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      name: "Clutterfly",
      source_url: @source_url
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
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.10"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:fly_machines, github: "ckreiling/fly_machines", tag: "0.2.0"},


    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      test: ["test"],
      "hex.build": ["format", "hex.build"]
    ]
  end

  defp description do
    """
    Wrap Fly Machines API requests, via ckreiling's FlyMachines API client, with body validation
    """
  end

  defp package do
    [
      name: :clutterfly,
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/clutterfly"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
