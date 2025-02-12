defmodule KantoxCashier.DiscountRulesTest do
  use ExUnit.Case
  alias KantoxCashier.DiscountRules

  describe "calculate_discount/3 for :buy_one_get_one" do
    test "returns correct total for an even count" do
      # For 4 items at 3.00 each, should charge for 2: 2 * 3.00 = 6.00.
      assert DiscountRules.calculate_discount({:buy_one_get_one}, 4, 3.0) == 6.0
    end

    test "returns correct total for an odd count" do
      # For 3 items at 3.00 each, should charge for 2: 2 * 3.00 = 6.00.
      assert DiscountRules.calculate_discount({:buy_one_get_one}, 3, 3.0) == 6.0
    end

    test "returns correct total for a single item" do
      assert DiscountRules.calculate_discount({:buy_one_get_one}, 1, 3.0) == 3.0
    end
  end

  describe "calculate_discount/3 for :bulk_fixed" do
    test "applies discount when count >= min_quantity" do
      # For 3 items at full price 5.00 each but discounted to 4.50 when 3 or more are bought:
      assert DiscountRules.calculate_discount({:bulk_fixed, 3, 4.50}, 3, 5.00) == 13.5
    end

    test "applies full price when count < min_quantity" do
      assert DiscountRules.calculate_discount({:bulk_fixed, 3, 4.50}, 2, 5.00) == 10.0
    end
  end

  describe "calculate_discount/3 for :bulk_factor" do
    test "applies discount when count >= min_quantity" do
      # For 3 items at unit price 11.23 with a discount factor of 2/3:
      discounted_unit_price = 11.23 * (2 / 3)

      assert DiscountRules.calculate_discount({:bulk_factor, 3, 2 / 3}, 3, 11.23) ==
               3 * discounted_unit_price
    end

    test "applies full price when count < min_quantity" do
      assert DiscountRules.calculate_discount({:bulk_factor, 3, 2 / 3}, 2, 11.23) == 2 * 11.23
    end
  end
end
