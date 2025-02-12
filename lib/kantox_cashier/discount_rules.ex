defmodule KantoxCashier.DiscountRules do
  @moduledoc """
  Contains discount strategies for products.
  """

  # Helper function to round to two decimals.
  defp r(value), do: Float.round(value, 2)

  # Calculates the total price for a product using the buy-one-get-one-free strategy.

  @spec calculate_discount({:buy_one_get_one}, non_neg_integer(), float()) :: float()
  def calculate_discount({:buy_one_get_one}, count, unit_price) do
    payable_units = div(count, 2) + rem(count, 2)
    r(payable_units * unit_price)
  end

  # Calculates the total price for a product using a bulk discount with a fixed price.

  # If the count is at least min_quantity, each unit is charged at fixed_price.
  # Otherwise, the full unit price applies.

  @spec calculate_discount({:bulk_fixed, non_neg_integer(), float()}, non_neg_integer(), float()) ::
          float()
  def calculate_discount({:bulk_fixed, min_quantity, fixed_price}, count, unit_price) do
    if count >= min_quantity do
      r(count * fixed_price)
    else
      r(count * unit_price)
    end
  end

  # Calculates the total price for a product using a bulk discount with a discount factor.

  # If the count is at least min_quantity, each unit is charged at (unit_price * factor).
  # Otherwise, the full unit price applies.

  @spec calculate_discount({:bulk_factor, non_neg_integer(), float()}, non_neg_integer(), float()) ::
          float()
  def calculate_discount({:bulk_factor, min_quantity, factor}, count, unit_price) do
    if count >= min_quantity do
      r(count * unit_price * factor)
    else
      r(count * unit_price)
    end
  end
end
