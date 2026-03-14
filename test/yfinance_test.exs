defmodule YfinanceTest do
  use ExUnit.Case
  doctest Yfinance

  describe "The Yfinance module" do
    test "should have the correct Python dependencies" do
      Enum.each(
        [
          "yfinance",
          "polars",
          "pyarrow"
        ],
        fn dep ->
          assert Yfinance.default_uv_init_def() =~ dep
        end
      )
    end
  end
end
