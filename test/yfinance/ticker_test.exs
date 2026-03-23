defmodule Yfinance.TickerTest do
  use ExUnit.Case

  alias Explorer.DataFrame
  alias Yfinance.Ticker

  doctest Yfinance.Ticker

  describe "Ticker.history!/4" do
    test "should return the correct columns when valid data is provided" do
      df =
        Ticker.history!(
          "aapl",
          Date.shift(Date.utc_today(), month: -1),
          Date.utc_today()
        )

      assert df
             |> DataFrame.names()
             |> Enum.sort() == ["adj_close", "close", "date", "high", "low", "open", "volume"]
    end

    test "should raise an error when invalid options are provided" do
      assert_raise RuntimeError, ~r"Yfinance encountered an error", fn ->
        Ticker.history!(
          "aapl",
          Date.shift(Date.utc_today(), month: -1),
          Date.utc_today(),
          actions: "BAD_INPUT"
        )
      end
    end
  end

  describe "Ticker.history_max!/2" do
    test "should return the correct columns when valid data is provided" do
      df = Ticker.history_max!("aapl")

      assert df
             |> DataFrame.names()
             |> Enum.sort() == ["adj_close", "close", "date", "high", "low", "open", "volume"]
    end

    test "should raise an error when invalid options are provided" do
      assert_raise RuntimeError, ~r"Yfinance encountered an error", fn ->
        Ticker.history_max!("aapl", actions: "BAD_INPUT")
      end
    end
  end

  describe "Ticker.income_statement!/2" do
    test "should return the correct columns when valid data is provided" do
      df = Ticker.income_statement!("aapl", :quarterly)

      assert df
             |> DataFrame.names()
             |> Enum.sort() == [
               "basic_average_shares",
               "basic_eps",
               "cost_of_revenue",
               "date",
               "diluted_average_shares",
               "diluted_eps",
               "diluted_ni_availto_com_stockholders",
               "ebit",
               "ebitda",
               "gross_profit",
               "net_income",
               "net_income_common_stockholders",
               "net_income_continuous_operations",
               "net_income_from_continuing_and_discontinued_operation",
               "net_income_from_continuing_operation_net_minority_interest",
               "net_income_including_noncontrolling_interests",
               "normalized_ebitda",
               "normalized_income",
               "operating_expense",
               "operating_income",
               "operating_revenue",
               "other_income_expense",
               "other_non_operating_income_expenses",
               "pretax_income",
               "reconciled_cost_of_revenue",
               "reconciled_depreciation",
               "research_and_development",
               "selling_general_and_administration",
               "tax_effect_of_unusual_items",
               "tax_provision",
               "tax_rate_for_calcs",
               "total_expenses",
               "total_operating_income_as_reported",
               "total_revenue"
             ]
    end

    test "should raise an error when invalid options are provided" do
      assert_raise CaseClauseError, ~r"no case clause matching", fn ->
        Ticker.income_statement!("aapl", :bad_input)
      end
    end
  end

  describe "Ticker.balance_sheet!/2" do
    test "should return the correct columns when valid data is provided" do
      df = Ticker.balance_sheet!("aapl", :quarterly)

      assert df
             |> DataFrame.names()
             |> Enum.sort() == [
               "accounts_payable",
               "accounts_receivable",
               "accumulated_depreciation",
               "available_for_sale_securities",
               "capital_stock",
               "cash_and_cash_equivalents",
               "cash_cash_equivalents_and_short_term_investments",
               "cash_equivalents",
               "cash_financial",
               "commercial_paper",
               "common_stock",
               "common_stock_equity",
               "current_accrued_expenses",
               "current_assets",
               "current_debt",
               "current_debt_and_capital_lease_obligation",
               "current_deferred_liabilities",
               "current_deferred_revenue",
               "current_liabilities",
               "date",
               "finished_goods",
               "gains_losses_not_affecting_retained_earnings",
               "gross_ppe",
               "income_tax_payable",
               "inventory",
               "invested_capital",
               "investmentin_financial_assets",
               "investments_and_advances",
               "land_and_improvements",
               "leases",
               "long_term_debt",
               "long_term_debt_and_capital_lease_obligation",
               "machinery_furniture_equipment",
               "net_debt",
               "net_ppe",
               "net_tangible_assets",
               "non_current_deferred_assets",
               "non_current_deferred_taxes_assets",
               "ordinary_shares_number",
               "other_current_assets",
               "other_current_borrowings",
               "other_current_liabilities",
               "other_equity_adjustments",
               "other_non_current_assets",
               "other_non_current_liabilities",
               "other_receivables",
               "other_short_term_investments",
               "payables",
               "payables_and_accrued_expenses",
               "properties",
               "raw_materials",
               "receivables",
               "retained_earnings",
               "share_issued",
               "stockholders_equity",
               "tangible_book_value",
               "total_assets",
               "total_capitalization",
               "total_debt",
               "total_equity_gross_minority_interest",
               "total_liabilities_net_minority_interest",
               "total_non_current_assets",
               "total_non_current_liabilities_net_minority_interest",
               "total_tax_payable",
               "tradeand_other_payables_non_current",
               "working_capital"
             ]
    end

    test "should raise an error when invalid options are provided" do
      assert_raise CaseClauseError, ~r"no case clause matching", fn ->
        Ticker.balance_sheet!("aapl", :bad_input)
      end
    end
  end

  describe "Ticker.cash_flow!/2" do
    test "should return the correct columns when valid data is provided" do
      df = Ticker.cash_flow!("aapl", :quarterly)

      assert df
             |> DataFrame.names()
             |> Enum.sort() == [
               "beginning_cash_position",
               "capital_expenditure",
               "cash_dividends_paid",
               "cash_flow_from_continuing_financing_activities",
               "cash_flow_from_continuing_investing_activities",
               "cash_flow_from_continuing_operating_activities",
               "change_in_account_payable",
               "change_in_inventory",
               "change_in_other_current_assets",
               "change_in_other_current_liabilities",
               "change_in_payable",
               "change_in_payables_and_accrued_expense",
               "change_in_receivables",
               "change_in_working_capital",
               "changes_in_account_receivables",
               "changes_in_cash",
               "common_stock_dividend_paid",
               "common_stock_payments",
               "date",
               "depreciation_amortization_depletion",
               "depreciation_and_amortization",
               "end_cash_position",
               "financing_cash_flow",
               "free_cash_flow",
               "income_tax_paid_supplemental_data",
               "investing_cash_flow",
               "issuance_of_debt",
               "long_term_debt_issuance",
               "long_term_debt_payments",
               "net_common_stock_issuance",
               "net_income_from_continuing_operations",
               "net_investment_purchase_and_sale",
               "net_issuance_payments_of_debt",
               "net_long_term_debt_issuance",
               "net_other_financing_charges",
               "net_other_investing_changes",
               "net_ppe_purchase_and_sale",
               "net_short_term_debt_issuance",
               "operating_cash_flow",
               "other_non_cash_items",
               "purchase_of_investment",
               "purchase_of_ppe",
               "repayment_of_debt",
               "repurchase_of_capital_stock",
               "sale_of_investment",
               "short_term_debt_payments",
               "stock_based_compensation"
             ]
    end

    test "should raise an error when invalid options are provided" do
      assert_raise CaseClauseError, ~r"no case clause matching", fn ->
        Ticker.cash_flow!("aapl", :bad_input)
      end
    end
  end
end
