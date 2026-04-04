<!--START-->
<p align="center">
  <img align="center" width="50%" src="guides/images/logo.png" alt="Yfinance Logo">
</p>

<p align="center">
  An Elixir wrapper for the <a href="https://github.com/ranaroussi/yfinance">Python yfinance</a> library.
</p>

<p align="center">
  <a href="https://hex.pm/packages/yfinance">
    <img alt="Hex.pm" src="https://img.shields.io/hexpm/v/yfinance?style=for-the-badge">
  </a>

  <a href="https://github.com/akoutmos/yfinance/actions">
    <img alt="GitHub Workflow Status (master)"
    src="https://img.shields.io/github/actions/workflow/status/akoutmos/yfinance/main.yml?label=Build%20Status&style=for-the-badge&branch=master">
  </a>

  <a href="https://coveralls.io/github/akoutmos/yfinance?branch=master">
    <img alt="Coveralls master branch" src="https://img.shields.io/coveralls/github/akoutmos/yfinance/master?style=for-the-badge">
  </a>

  <a href="https://github.com/sponsors/akoutmos">
    <img alt="Support YFinance" src="https://img.shields.io/badge/Support%20Yfinance-%E2%9D%A4-lightblue?style=for-the-badge">
  </a>
</p>

<br>
<!--END-->

Yahoo! Finance® is a great place to download financial data like stock ticker prices. While they don't offer an API from
which you can download this data, there is a [Python library](https://github.com/ranaroussi/yfinance) that makes the
same calls as their web app so that you can fetch the time series data. This library was written to allow readers of
[Financial Analytics Using Elixir](https://financialanalytics.dev) to collect, analyze and visualize economic data from
Yahoo! Finance®, but it can be used outside the context of the book.

To learn how you can analyze and visualize the financial markets using Livebook, Explorer, Scholar and Nx, be sure to pick up
a copy of our book:

<p align="center">
  <a href="https://www.financialelixir.dev/">
    <img width="50%" src="guides/images/book_cover.png" alt="Financial Analytics Using Elixir book cover">
  </a>
</p>

# Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Quick Start](#quick-start)
- [Livebook Notebooks](#livebook-notebooks)

## Installation

Add `yfinance` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yfinance, "~> 0.6.0"}
  ]
end
```

## Configuration

In order to run the underlying [Python yfinance library](https://github.com/ranaroussi/yfinance), this library makes use
of [Pythonx](https://github.com/livebook-dev/pythonx) so that you can run Python code inside your Elixir application. By
default `Yfinance` will attempt to start the Python runtime as part of application init, but if you attempt to start two
instances of Pythonx, `Yfinance` will assume that you have started it via
[configuration](https://hexdocs.pm/pythonx/Pythonx.html#module-usage-application) and it is up to you to configure your
Python runtime properly.

For more information on how you can do this, check out the docs for `Yfinance`.

## Quick Start

Once you have the Yfinance library added to your `mix.exs` file, you can start your project with `ex -S mix` and run
queries to Yahoo! Finance® like so:

```elixir
iex(1)> {:ok, data_frame} = Yfinance.Ticker.history("aapl", Date.shift(Date.utc_today(), month: -1), Date.utc_today())
{:ok,
 #Explorer.DataFrame<
   Polars[19 x 7]
   Date date [2026-02-13, 2026-02-17, 2026-02-18, 2026-02-19, 2026-02-20, ...]
   aapl_Adj Close decimal[38, 2] [255.78, 263.88, 264.35, 260.58, 264.58, ...]
   aapl_Close decimal[38, 2] [255.78, 263.88, 264.35, 260.58, 264.58, ...]
   aapl_High decimal[38, 2] [262.23, 266.29, 266.82, 264.48, 264.75, ...]
   aapl_Low decimal[38, 2] [255.45, 255.54, 262.45, 260.05, 258.16, ...]
   aapl_Open decimal[38, 2] [262.01, 258.05, 263.60, 262.60, 258.97, ...]
   aapl_Volume s64 [56290700, 58469100, 34203300, 30845300, 42070500, ...]
 >}

iex(2)> Explorer.DataFrame.print(data_frame, limit: 10, limit_dots: :bottom)
+-------------------------------------------------------------------------------------------------------------------------+
|                                       Explorer DataFrame: [rows: 19, columns: 7]                                        |
+------------+------------------+------------------+------------------+------------------+------------------+-------------+
|    date    |  aapl_Adj Close  |    aapl_Close    |    aapl_High     |     aapl_Low     |    aapl_Open     | aapl_Volume |
|   <date>   | <decimal[38, 2]> | <decimal[38, 2]> | <decimal[38, 2]> | <decimal[38, 2]> | <decimal[38, 2]> |    <s64>    |
+============+==================+==================+==================+==================+==================+=============+
| 2026-02-13 | 255.78           | 255.78           | 262.23           | 255.45           | 262.01           | 56290700    |
| 2026-02-17 | 263.88           | 263.88           | 266.29           | 255.54           | 258.05           | 58469100    |
| 2026-02-18 | 264.35           | 264.35           | 266.82           | 262.45           | 263.60           | 34203300    |
| 2026-02-19 | 260.58           | 260.58           | 264.48           | 260.05           | 262.60           | 30845300    |
| 2026-02-20 | 264.58           | 264.58           | 264.75           | 258.16           | 258.97           | 42070500    |
| 2026-02-23 | 266.18           | 266.18           | 269.43           | 263.38           | 263.49           | 37308200    |
| 2026-02-24 | 272.14           | 272.14           | 274.89           | 267.71           | 267.86           | 47014600    |
| 2026-02-25 | 274.23           | 274.23           | 274.94           | 271.05           | 271.78           | 33714300    |
| 2026-02-26 | 272.95           | 272.95           | 276.11           | 270.80           | 274.95           | 32345100    |
| 2026-02-27 | 264.18           | 264.18           | 272.81           | 262.89           | 272.81           | 72366500    |
| …          | …                | …                | …                | …                | …                | …           |
+------------+------------------+------------------+------------------+------------------+------------------+-------------+

:ok
```

## Livebook Notebooks

The `livebooks/` directory contains interactive [Livebook](https://livebook.dev) notebooks that demonstrate how to use
the library along with [VegaLite](https://hexdocs.pm/vega_lite) for charting:

| Notebook                                                                                | Description                        |
| --------------------------------------------------------------------------------------- | ---------------------------------- |
| [`1_plotting_ticker_data.livemd`](./livebooks/1_plotting_ticker_data.livemd)            | Plot basic ticker time series data |
| [`2_plotting_ticker_financials.livemd`](./livebooks/2_getting_ticker_financials.livemd) | Plot basic ticker financials       |
