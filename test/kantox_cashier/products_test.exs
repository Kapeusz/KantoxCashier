defmodule KantoxCashier.ProductsTest do
  use ExUnit.Case
  alias KantoxCashier.Products

  describe "all/0" do
    test "returns the complete products map" do
      products = Products.all()
      assert is_map(products)
      assert Map.has_key?(products, "GR1")
      assert Map.has_key?(products, "SR1")
      assert Map.has_key?(products, "CF1")
    end
  end

  describe "get/1" do
    test "returns the product for GR1" do
      product = Products.get("GR1")
      assert product != nil
      assert product.name == "Green tea"
      assert product.price == 3.11
      assert product.discount == {:buy_one_get_one}
    end

    test "returns the product for SR1" do
      product = Products.get("SR1")
      assert product != nil
      assert product.name == "Strawberries"
      assert product.price == 5.00
      assert product.discount == {:bulk_fixed, 3, 4.50}
    end

    test "returns the product for CF1" do
      product = Products.get("CF1")
      assert product != nil
      assert product.name == "Coffee"
      assert product.price == 11.23
      assert product.discount == {:bulk_factor, 3, 2 / 3}
    end

    test "returns nil for an unknown product code" do
      assert Products.get("UNKNOWN") == nil
    end
  end

  describe "price/1" do
    test "returns {:ok, price} for a valid product code" do
      assert Products.price("GR1") == {:ok, 3.11}
      assert Products.price("SR1") == {:ok, 5.00}
      assert Products.price("CF1") == {:ok, 11.23}
    end

    test "returns {:error, code, :unknown_product} for an unknown product code" do
      assert Products.price("XYZ") == {:error, "XYZ", :unknown_product}
    end
  end
end
