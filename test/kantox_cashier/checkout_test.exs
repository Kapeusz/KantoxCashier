defmodule KantoxCashier.CheckoutTest do
  use ExUnit.Case
  alias KantoxCashier.Checkout

  describe "scanning and total calculation" do
    test "Basket: GR1, SR1, GR1, GR1, CF1 -> total £22.45" do
      # Breakdown:
      # GR1 (buy-one-get-one): 3 items -> pay for 2 * 3.11 = 6.22
      # SR1 (bulk_fixed, discount applies only if count>=3): 1 item -> full price 5.00
      # CF1 (bulk_factor, discount applies only if count>=3): 1 item -> full price 11.23
      # Total = 6.22 + 5.00 + 11.23 = 22.45
      {:ok, checkout} = Checkout.new() |> Checkout.scan("GR1")
      {:ok, checkout} = Checkout.scan(checkout, "SR1")
      {:ok, checkout} = Checkout.scan(checkout, "GR1")
      {:ok, checkout} = Checkout.scan(checkout, "GR1")
      {:ok, checkout} = Checkout.scan(checkout, "CF1")

      assert Checkout.total(checkout) == {:ok, 22.45}
    end

    test "Basket: GR1, GR1 -> total £3.11" do
      # For 2 GR1 items with buy-one-get-one, only 1 is charged: 1 * 3.11 = 3.11.
      {:ok, checkout} = Checkout.new() |> Checkout.scan("GR1")
      {:ok, checkout} = Checkout.scan(checkout, "GR1")

      assert Checkout.total(checkout) == {:ok, 3.11}
    end

    test "Basket: SR1, SR1, GR1, SR1 -> total £16.61" do
      # For SR1: 3 items -> bulk_fixed discount applies: 3 * 4.50 = 13.50.
      # For GR1: 1 item -> 3.11.
      # Total = 13.50 + 3.11 = 16.61.
      {:ok, checkout} = Checkout.new() |> Checkout.scan("SR1")
      {:ok, checkout} = Checkout.scan(checkout, "SR1")
      {:ok, checkout} = Checkout.scan(checkout, "GR1")
      {:ok, checkout} = Checkout.scan(checkout, "SR1")

      assert Checkout.total(checkout) == {:ok, 16.61}
    end

    test "Basket: GR1, CF1, SR1, CF1, CF1 -> total £30.57" do
      # For GR1: 1 item = 3.11.
      # For CF1: 3 items -> bulk_factor discount applies:
      #   Each CF1 costs 11.23 * (2/3) ≈ 7.49, so 3 * 7.49 = 22.47.
      # For SR1: 1 item = 5.00.
      # Total = 3.11 + 22.47 + 5.00 = 30.58 (rounding may yield 30.57).
      {:ok, checkout} = Checkout.new() |> Checkout.scan("GR1")
      {:ok, checkout} = Checkout.scan(checkout, "CF1")
      {:ok, checkout} = Checkout.scan(checkout, "SR1")
      {:ok, checkout} = Checkout.scan(checkout, "CF1")
      {:ok, checkout} = Checkout.scan(checkout, "CF1")

      assert Checkout.total(checkout) == {:ok, 30.57}
    end

    test "Handling unknown products: immediate validation" do
      checkout = Checkout.new()

      # Scan a valid product.
      {:ok, checkout} = Checkout.scan(checkout, "GR1")

      # Scan an unknown product; expect an error and the checkout remains unchanged.
      assert {:error, "UNKNOWN", :unknown_product} = Checkout.scan(checkout, "UNKNOWN")

      # Scan another valid product.
      {:ok, checkout} = Checkout.scan(checkout, "CF1")

      # Scan another unknown product.
      assert {:error, "UNKNOWN2", :unknown_product} = Checkout.scan(checkout, "UNKNOWN2")

      # The final checkout should only contain "GR1" and "CF1".
      # Total = 3.11 + 11.23 = 14.34.
      assert Checkout.total(checkout) == {:ok, 14.34}
    end
  end
end
