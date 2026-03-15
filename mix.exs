defmodule Yfinance.MixProject do
  use Mix.Project

  def project do
    [
      app: :yfinance,
      version: project_version(),
      elixir: "~> 1.18",
      name: "YFinance",
      source_url: "https://github.com/akoutmos/yfinance",
      homepage_url: "https://hex.pm/packages/yfinance",
      description: "An Elixir client for the Federal Reserve Economic Data API",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/project.plt"}
      ],
      test_coverage: [
        ignore_modules: [Yfinance.Utils],
        summary: [
          threshold: 75
        ]
      ]
      # test_coverage: [tool: ExCoveralls],
      # preferred_cli_env: [
      #   coveralls: :test,
      #   "coveralls.detail": :test,
      #   "coveralls.post": :test,
      #   "coveralls.html": :test,
      #   "coveralls.cobertura": :test
      # ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Yfinance.Application, []}
    ]
  end

  defp package do
    [
      name: "yfinance",
      files: ~w(lib livebooks mix.exs README.md LICENSE CHANGELOG.md VERSION),
      licenses: ["MIT"],
      maintainers: ["Alex Koutmos"],
      links: %{
        "GitHub" => "https://github.com/akoutmos/yfinance",
        "Sponsor" => "https://github.com/sponsors/akoutmos"
      }
    ]
  end

  defp docs do
    livebooks =
      __DIR__
      |> Path.join("livebooks")
      |> File.ls!()
      |> Enum.map(fn livebook ->
        Path.join("livebooks", livebook)
      end)
      |> Enum.sort()

    [
      main: "readme",
      source_ref: "master",
      logo: "guides/images/logo.png",
      extras: ["README.md", "CHANGELOG.md" | livebooks],
      groups_for_extras: [
        General: ["README.md", "CHANGELOG.md"],
        Livebooks: Path.wildcard("livebooks/*.livemd")
      ]
    ]
  end

  defp deps do
    [
      # Required dependencies
      {:nimble_options, "~> 1.0"},
      {:pythonx, "~> 0.4"},
      {:explorer, "~> 0.11"},

      # Development deps
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev},
      {:doctor, "~> 0.22", only: :dev},

      # Test deps
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp aliases do
    [
      docs: [&massage_readme/1, "docs", &copy_files/1, &revert_readme/1]
    ]
  end

  defp project_version do
    "VERSION"
    |> File.read!()
    |> String.trim()
  end

  defp copy_files(_) do
    # Set up directory structure
    File.mkdir_p!("./doc/guides/images")

    # Copy over image files
    "./guides/images/"
    |> File.ls!()
    |> Enum.each(fn image_file ->
      File.cp!("./guides/images/#{image_file}", "./doc/guides/images/#{image_file}")
    end)
  end

  defp revert_readme(_) do
    File.cp!("./README.md.orig", "./README.md")
    File.rm!("./README.md.orig")
  end

  defp massage_readme(_) do
    hex_docs_friendly_header_content = """
    <br>
    <img align="center" width="50%" src="guides/images/logo.png" alt="Yfinance Logo" style="margin-left:25%">
    <br>
    <div align="center"></div>
    <br>
    --------------------

    [![Hex.pm](https://img.shields.io/hexpm/v/yfinance?style=for-the-badge)](http://hex.pm/packages/yfinance)
    [![Build Status](https://img.shields.io/github/actions/workflow/status/akoutmos/yfinance/main.yml?label=Build%20Status&style=for-the-badge&branch=master)](https://github.com/akoutmos/yfinance/actions)
    [![Coverage Status](https://img.shields.io/coveralls/github/akoutmos/yfinance/master?style=for-the-badge)](https://coveralls.io/github/akoutmos/yfinance?branch=master)
    [![Support Yfinance](https://img.shields.io/badge/Support%20Yfinance-%E2%9D%A4-lightblue?style=for-the-badge)](https://github.com/sponsors/akoutmos)
    """

    File.cp!("./README.md", "./README.md.orig")

    readme_contents = File.read!("./README.md")

    massaged_readme =
      Regex.replace(
        ~r/<!--START-->(.|\n)*<!--END-->/,
        readme_contents,
        hex_docs_friendly_header_content
      )

    File.write!("./README.md", massaged_readme)
  end
end
