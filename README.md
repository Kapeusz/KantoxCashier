# KantoxCashier

KantoxCashier is a simple checkout system built in Elixir for a small chain of supermarkets. The application demonstrates a flexible pricing engine that adapts to changing discount rules using a Test-Driven Development (TDD) approach.

## Overview

This system provides a cashier function that adds products to a cart and calculates the total price by applying configurable discount rules. It includes the following test products:

| Product Code | Name         | Price  |
| ------------ | ------------ | ------ |
| **GR1**      | Green tea    | £3.11  |
| **SR1**      | Strawberries | £5.00  |
| **CF1**      | Coffee       | £11.23 |

### Special Discount Rules

- **Buy-One-Get-One-Free**  
  Green tea (GR1) is eligible for a buy-one-get-one-free offer.
  
- **Bulk Discount (Fixed Price)**  
  Strawberries (SR1) are discounted to £4.50 each when 3 or more are purchased.
  
- **Bulk Discount (Discount Factor)**  
  Coffee (CF1) is discounted to two-thirds of its original price when 3 or more are purchased.

The checkout system scans items in any order. If an unknown product is scanned, an immediate error is returned (allowing the cashier to either skip it or re-enter the correct code) and that product is not added to the cart. Valid items remain, and the final total is calculated only from the known products.

## Project Structure

- **KantoxCashier.Products**  
  Provides access to product information and discount configuration. Each product is defined with its name, price, and discount tuple (for example, `{:buy_one_get_one}` for GR1).

- **KantoxCashier.DiscountRules**  
  Contains discount strategies. It implements rules for buy-one-get-one-free, bulk discounts with a fixed price, and bulk discounts using a discount factor. Each rule rounds its result to two decimal places.

- **KantoxCashier.Checkout**  
  Manages scanning of product codes and calculates the final total. It validates product codes immediately during scanning so that unknown codes are flagged and not added to the checkout.

## Usage

The project was built with:

```elixir
Elixir 1.17.1 (compiled with Erlang/OTP 27)
```

Clone the repository and install dependencies:

```bash
git clone https://github.com/Kapeusz/KantoxCashier.git
cd KantoxCashier
mix deps.get
```

Start an interactive Elixir shell:

```bash
iex -S mix
```

Example usage in IEx:

```elixir
# Create a new checkout
{:ok, checkout} = KantoxCashier.Checkout.new()
  |> KantoxCashier.Checkout.scan("GR1")
  |> KantoxCashier.Checkout.scan("SR1")
  |> KantoxCashier.Checkout.scan("GR1")
  |> KantoxCashier.Checkout.scan("GR1")
  |> KantoxCashier.Checkout.scan("CF1")

# Calculate the total
KantoxCashier.Checkout.total(checkout)
# Expected output: {:ok, 22.45}
```

If an unknown product is scanned:

```elixir
# Attempt to scan an unknown product
{:error, "UNKNOWN", :unknown_product} = KantoxCashier.Checkout.scan(checkout, "UNKNOWN")
```

The final total calculation ignores unknown codes, so valid items are still totaled.

## Note on Price/Currency Handling

For simplicity, no external libraries for price or currency handling were used. All arithmetic is performed using Elixir's built-in floating-point operations, with rounding applied as needed.

## Test Data & Expected Totals

- **Basket:** GR1, SR1, GR1, GR1, CF1 -> **Total:** £22.45  
- **Basket:** GR1, GR1 -> **Total:** £3.11  
- **Basket:** SR1, SR1, GR1, SR1 -> **Total:** £16.61  
- **Basket:** GR1, CF1, SR1, CF1, CF1 -> **Total:** £30.57  

Unknown products are immediately rejected when scanned. The checkout only retains valid products, and the total is calculated accordingly.

## Testing

To run the test suite, execute:

```bash
mix test
```

The tests cover:
- Validation of product information and discount configurations.
- Checkout functionality for various baskets.
- Immediate error handling for unknown product codes.
