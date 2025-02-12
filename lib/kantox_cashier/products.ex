defmodule KantoxCashier.Products do
  @moduledoc """
  Provides access to product information.
  """

  @type product :: %{
          name: String.t(),
          price: float(),
          discount: tuple()
        }
  @type products :: %{String.t() => product()}

  @products %{
    "GR1" => %{
      name: "Green tea",
      price: 3.11,
      discount: {:buy_one_get_one}
    },
    "SR1" => %{
      name: "Strawberries",
      price: 5.00,
      discount: {:bulk_fixed, 3, 4.50}
    },
    "CF1" => %{
      name: "Coffee",
      price: 11.23,
      discount: {:bulk_factor, 3, 2 / 3}
    }
  }

  @spec all() :: products()
  def all, do: @products

  @spec get(String.t()) :: product() | nil
  def get(code), do: Map.get(@products, code)

  @spec price(String.t()) :: {:ok, float()} | {:error, String.t(), :unknown_product}
  def price(code) do
    case get(code) do
      nil -> {:error, code, :unknown_product}
      %{price: price} -> {:ok, price}
    end
  end
end
