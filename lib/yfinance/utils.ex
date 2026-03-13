defmodule Yfinance.Utils do
  @moduledoc false

  alias Yfinance.Error

  @doc false
  def validate_opts(opts, schema) do
    case NimbleOptions.validate(opts, schema) do
      {:ok, _validated_opts} ->
        :ok

      {:error, %NimbleOptions.ValidationError{} = error} ->
        message = Exception.message(error)
        {:error, Error.new(:option_error, message)}
    end
  end

  @doc false
  def generate_schema(fields) do
    fields
    |> Enum.flat_map(fn field ->
      generate_field_spec(field)
    end)
    |> Enum.sort_by(fn {field, _spec} ->
      field
    end)
    |> NimbleOptions.new!()
  end

  defp generate_field_spec({:string_enum, field, description, possible_values}) do
    keys =
      if Keyword.keyword?(possible_values) do
        Keyword.keys(possible_values)
      else
        possible_values
      end

    [
      {field,
       [
         doc: "#{description} #{generate_in_doc_list(possible_values)}",
         type: {:in, keys},
         type_doc: "`t:String.t/0`"
       ]}
    ]
  end

  defp generate_field_spec({:date, field, description}) do
    [
      {field,
       [
         doc: description,
         type: {:struct, Date}
       ]}
    ]
  end

  defp generate_field_spec({:boolean, field, description}) do
    [
      {field,
       [
         doc: description,
         type: :boolean
       ]}
    ]
  end

  defp generate_field_spec(:interval) do
    generate_field_spec(
      {:string_enum, :interval, "The interval for the query.",
       ["1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo"]}
    )
  end

  defp generate_field_spec(:period) do
    generate_field_spec(
      {:string_enum, :period, "The period for the query.",
       ["1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max"]}
    )
  end

  defp generate_in_doc_list(sortable_fields) do
    value_list =
      sortable_fields
      |> Enum.map_join("\n", fn
        {field, description} ->
          "- `#{inspect(field)}` - #{description}"

        field ->
          "- `#{inspect(field)}`"
      end)

    "Supported values are:\n#{value_list}"
  end
end
