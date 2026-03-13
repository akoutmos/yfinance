defmodule Yfinance do
  @moduledoc """
  Documentation for `Yfinance`.
  """

  @version Mix.Project.config()[:version]

  @doc """
  This function returns the default Pythonx.uv_init toml
  definition.
  """
  def default_uv_init_def do
    """
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
  end
end
