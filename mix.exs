defmodule Hyperliquid.MixProject do
  use Mix.Project

  @source_url "https://github.com/skedzior/hyperliquid"
  @version "0.1.6"

  def project do
    [
      app: :hyperliquid,
      version: @version,
      elixir: "~> 1.20.2",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Hyperliquid.Application, []}
    ]
  end

  defp package do
    [
      description: "Elixir api wrapper for the Hyperliquid exchange",
      maintainers: ["Steven Kedzior"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.2"},
      {:httpoison, "~> 3.0"},
      {:jason, "~> 1.4.5"},
      {:websockex, "~> 0.5.1"},
      {:cachex, "~> 4.1"},
      {:ex_eip712, "~> 0.3.0"},
      {:ethers, "~> 0.8"},
      {:msgpax, "~> 2.4"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
