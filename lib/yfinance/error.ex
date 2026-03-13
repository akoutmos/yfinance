defmodule Yfinance.Error do
  @moduledoc """
  Structured error type for Yfinance errors.

  ## Error Types

    - `:option_error` - The provided options for a given function were malformed.
    - `:python_error` - Something failed on the Python side of things.
  """

  @type error_type :: :option_error | :python_error

  @type t :: %__MODULE__{
          type: error_type(),
          message: String.t()
        }

  defexception [:type, :message]

  @doc false
  def new(type, message) do
    %__MODULE__{type: type, message: message}
  end

  @impl true
  def message(%__MODULE__{type: type, message: message}) do
    "(#{type}) #{message}"
  end
end
