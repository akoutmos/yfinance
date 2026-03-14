defmodule Yfinance.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    # Start the Pythonx runtime if it has not already been started
    try do
      Pythonx.uv_init(Yfinance.default_uv_init_def())
    rescue
      _error in RuntimeError ->
        Logger.info("Yfinance has skipped starting Pythonx as it was already initialized")
    end

    opts = [strategy: :one_for_one, name: Yfinance.Supervisor]
    Supervisor.start_link([], opts)
  end
end
