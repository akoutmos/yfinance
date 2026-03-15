defmodule Yfinance.Ticker do
  @moduledoc """
  This module allows you to fetch ticker data from Yahoo! Finance®. At the moment you
  can fetch data on the financials of a stock ticker as well as the historical ticker
  price. More functions are coming soon!
  """

  alias Explorer.DataFrame
  alias Yfinance.Error
  alias Yfinance.Utils

  @type result :: {:ok, DataFrame.t()} | {:error, term()}

  @history_schema Utils.generate_schema([
                    {:boolean, :prepost, "Whether to include pre/post market data."},
                    {:boolean, :auto_adjust, "Whether to adjust OHLC for splits."},
                    {:boolean, :actions, "Whether to include dividends and stock splits."}
                  ])

  @doc """
  Get the OHLCV history for a provided stock symbol given a start and end date. The result is
  an `Explorer.DataFrame` struct.

  ## Options

    #{NimbleOptions.docs(@history_schema)}

  ## Examples

      iex> {:ok, data_frame} =
      ...>   Yfinance.Ticker.history("aapl", Date.shift(Date.utc_today(), month: -1), Date.utc_today())
      iex> %Explorer.DataFrame{} = data_frame

      iex> {:ok, data_frame} =
      ...>   Yfinance.Ticker.history("aapl", Date.shift(Date.utc_today(), month: -1), Date.utc_today())
      iex> %Explorer.DataFrame{} = data_frame

      iex> {:error, %Yfinance.Error{type: :option_error}} =
      ...>   Yfinance.Ticker.history(
      ...>     "aapl",
      ...>     Date.shift(Date.utc_today(), month: -1),
      ...>     Date.utc_today(),
      ...>     actions: "BAD_INPUT"
      ...>   )
  """
  @spec history(
          symbol :: String.t(),
          state_date :: Date.t(),
          end_date :: Date.t(),
          opts :: keyword()
        ) :: result
  def history(symbol, %Date{} = start_date, %Date{} = end_date, opts \\ []) do
    with :ok <- Utils.validate_opts(opts, @history_schema) do
      variables = %{
        "symbol" => symbol,
        "start" => Date.to_string(start_date),
        "end" => Date.to_string(end_date),
        "prepost" => Keyword.get(opts, :prepost),
        "auto_adjust" => Keyword.get(opts, :auto_adjust),
        "actions" => Keyword.get(opts, :actions),
        "progress" => false,
        "threads" => false
      }

      python_code = """
      import yfinance as yf
      import polars as pl
      import io

      #{decode_function()}

      hist = yf.download(
          tickers=decode(symbol),
          start=decode(start),
          end=decode(end),
          prepost=prepost,
          auto_adjust=auto_adjust,
          actions=actions,
          progress=progress,
          threads=threads
      )

      # Reset index to make Date a column
      hist = hist.reset_index()

      # Flatten multi-level columns (yfinance often returns these)
      if hasattr(hist.columns, 'nlevels') and hist.columns.nlevels > 1:
          hist.columns = [col[0] if col[1] == '' else f'{col[1]}_{col[0]}' for col in hist.columns.values]

      # Convert pandas DataFrame to Polars
      hist.columns = [str(col).replace(' ', '_').lower().removeprefix(decode(symbol) + '_') for col in hist.columns]
      pl_df = pl.from_pandas(hist)

      pl_df = pl_df.with_columns(
        pl.col(pl.Float64).cast(pl.Decimal(scale=2))
      )

      # Cast Date column to date type (removes time component)
      if "Date" in pl_df.columns:
          pl_df = pl_df.with_columns(pl.col("Date").cast(pl.Date))

      # Serialize to Arrow IPC bytes
      buffer = io.BytesIO()
      pl_df.write_ipc(buffer)
      ipc_bytes = buffer.getvalue()

      ipc_bytes
      """

      eval_and_load_arrow_ipc(python_code, variables)
    end
  end

  @doc """
  Get the income statement history for a provided stock symbol. The result is
  an `Explorer.DataFrame` struct.

  ## Examples

      iex> {:ok, data_frame} =
      ...>   Yfinance.Ticker.income_statement("aapl", :quarterly)
      iex> %Explorer.DataFrame{} = data_frame
  """
  @spec income_statement(symbol :: String.t(), frequency :: :yearly | :quarterly) :: result
  def income_statement(symbol, frequency) do
    get_financial_statement(symbol, :income_stmt, frequency)
  end

  @doc """
  Get the balance sheet history for a provided stock symbol. The result is
  an `Explorer.DataFrame` struct.

  ## Examples

      iex> {:ok, data_frame} =
      ...>   Yfinance.Ticker.balance_sheet("aapl", :quarterly)
      iex> %Explorer.DataFrame{} = data_frame
  """
  @spec balance_sheet(symbol :: String.t(), frequency :: :yearly | :quarterly) :: result
  def balance_sheet(symbol, frequency) do
    get_financial_statement(symbol, :balance_sheet, frequency)
  end

  @doc """
  Get the cash flow history for a provided stock symbol. The result is
  an `Explorer.DataFrame` struct.

  ## Examples

      iex> {:ok, data_frame} =
      ...>   Yfinance.Ticker.cash_flow("aapl", :quarterly)
      iex> %Explorer.DataFrame{} = data_frame
  """
  @spec cash_flow(symbol :: String.t(), frequency :: :yearly | :quarterly) :: result
  def cash_flow(symbol, frequency) do
    get_financial_statement(symbol, :cashflow, frequency)
  end

  # +--------------------------------------------+
  # |              Helper functions              |
  # +--------------------------------------------+

  defp get_financial_statement(symbol, statement_type, frequency) do
    attr =
      case frequency do
        :quarterly -> "quarterly_#{statement_type}"
        :yearly -> statement_type
      end

    variables = %{
      "symbol" => symbol,
      "attr" => attr
    }

    python_code = """
    import yfinance as yf
    import polars as pl
    import io

    #{decode_function()}

    ticker = yf.Ticker(decode(symbol))
    stmt = getattr(ticker, decode(attr))

    # Financial statements have dates as columns and items as rows
    # Transpose to have dates as rows
    df = stmt.T.reset_index()
    df = df.rename(columns={'index': 'Date'})

    # Normalize column names
    df.columns = [str(col).replace(' ', '_').lower() for col in df.columns]
    pl_df = pl.from_pandas(df)

    # Cast Date column to date type
    if "Date" in pl_df.columns:
        pl_df = pl_df.with_columns(pl.col("Date").cast(pl.Date))

    buffer = io.BytesIO()
    pl_df.write_ipc(buffer)
    ipc_bytes = buffer.getvalue()

    ipc_bytes
    """

    eval_and_load_arrow_ipc(python_code, variables)
  end

  defp decode_function do
    """
    def decode(value):
      if value == None:
        return None
      else:
        return value.decode("utf-8")
    """
  end

  defp eval_and_load_arrow_ipc(python_code, variables) do
    {result, _globals} = Pythonx.eval(python_code, variables)
    ipc_bytes = Pythonx.decode(result)

    case DataFrame.load_ipc(ipc_bytes) do
      {:ok, data_frame} ->
        {:ok, data_frame}

      {:error, reason} ->
        {:error, Error.new(:python_error, "Failed to load IPC data: #{inspect(reason)}")}
    end
  rescue
    error ->
      {:error, Exception.message(error)}
  end
end
