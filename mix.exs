defmodule Yfinance.MixProject do
  use Mix.Project

  def project do
    [
      app: :yfinance,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Yfinance.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.0"},
      {:pythonx, "~> 0.4"},
      {:explorer, "~> 0.11"}
    ]
  end
end
