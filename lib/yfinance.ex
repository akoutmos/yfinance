defmodule Yfinance do
  @version Mix.Project.config()[:version]

  @default_uv_init_def """
  [project]
  name = "yfinance_ex"
  version = "#{@version}"
  requires-python = "==3.14.*"
  dependencies = [
    "yfinance>=1.2.0",
    "polars>=1.39.0",
    "pyarrow>=23.0.0"
  ]
  """

  @moduledoc """
  This Elixir library provides a wrapper around the [Python yfinance](https://github.com/ranaroussi/yfinance)
  so that you can fetch stock price data from Yahoo! Finance.

  ## Setup

  In order to run the underlying Python yfinance library, this library makes use of
  [Pythonx](https://github.com/livebook-dev/pythonx) so that you can run Python
  code inside your Elixir application. By default `Yfinance` will attempt to start
  the Python runtime as part of application init, but if you attempt to start two
  instances of Python `Yfinance` will assume that you have started it via
  [configuration](https://hexdocs.pm/pythonx/Pythonx.html#module-usage-application).

  If you do start Pythonx via your application configuration, simply make sure you add
  the dependencies that this wrapper needs. Below is the default `un_init` that this
  library uses for refernce:


  ```toml
  #{@default_uv_init_def}
  ```
  """

  @doc """
  This function returns the default Pythonx.uv_init toml
  definition.
  """
  def default_uv_init_def do
    @default_uv_init_def
  end
end
