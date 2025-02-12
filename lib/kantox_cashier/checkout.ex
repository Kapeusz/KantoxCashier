defmodule KantoxCashier.Checkout do
  @moduledoc """
  Handles checkout operations by scanning product codes and calculating totals.

  When scanning, the product code is immediately validated:
    - If the code is known, it is added to the checkout.
    - If the code is unknown, an error is returned immediately and the checkout remains unchanged.

  The final total is computed only from valid products.
  """
  alias KantoxCashier.Products
  alias KantoxCashier.DiscountRules

  defstruct items: []

  @type t :: %__MODULE__{items: [String.t()]}

  @doc """
  Returns a new, empty checkout.
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Scans a product code and updates the checkout.

  Returns:
    - `{:ok, updated_checkout}` if the product code is valid.
    - `{:error, product_code, :unknown_product}` if the code is unknown.
  """
  @spec scan(t(), String.t()) :: {:ok, t()} | {:error, String.t(), :unknown_product}
  def scan(%__MODULE__{items: items} = checkout, product_code) do
    case Products.get(product_code) do
      nil ->
        {:error, product_code, :unknown_product}

      _product ->
        {:ok, %__MODULE__{checkout | items: items ++ [product_code]}}
    end
  end

  @doc """
  Calculates the total for the checkout from valid scanned products.

  Returns `{:ok, total}` (rounded to two decimals).
  """
  @spec total(t()) :: {:ok, float()}
  def total(%__MODULE__{items: items}) do
    total =
      items
      |> Enum.frequencies()
      |> Enum.map(fn {code, count} ->
        # Since unknown codes are not added via scan/2, this should always succeed.
        case Products.get(code) do
          nil ->
            0.0

          %{price: unit_price, discount: discount} ->
            DiscountRules.calculate_discount(discount, count, unit_price)
        end
      end)
      |> Enum.sum()

    {:ok, Float.round(total, 2)}
  end
end
