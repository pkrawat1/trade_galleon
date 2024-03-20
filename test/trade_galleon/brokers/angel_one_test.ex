defmodule TradeGalleon.Brokers.AngelOneTest do
  use ExUnit.Case
  doctest TradeGalleon.Brokers.AngelOne
  alias TradeGalleon.Brokers.AngelOne, as: Broker

  @config [
    {:api_key, "api_key"},
    {:local_ip, "0.0.0.0"},
    {:public_ip, "0.0.0.0"},
    {:mac_address, "ff:ff::ff::ff"},
    {:secret_key, "secret_key"}
  ]
  @base_url "https://apiconnect.angelbroking.com"
  @routes %{
    "login" => {"rest/auth/angelbroking/user/v1/loginByPassword", :post},
    "logout" => {"rest/secure/angelbroking/user/v1/logout", :post},
    "generate_token" => {"rest/auth/angelbroking/jwt/v1/generateTokens", :post},
    "profile" => {"rest/secure/angelbroking/user/v1/getProfile", :get},
    "portfolio" => {"rest/secure/angelbroking/portfolio/v1/getHolding", :get},
    "quote" => {"rest/secure/angelbroking/market/v1/quote", :post},
    "candle_data" => {"rest/secure/angelbroking/historical/v1/getCandleData", :post},
    "funds" => {"rest/secure/angelbroking/user/v1/getRMS", :get},
    "order_book" => {"/rest/secure/angelbroking/order/v1/getOrderBook", :post},
    "trade_book" => {"rest/secure/angelbroking/order/v1/getTradeBook", :post},
    "search_token" => {"rest/secure/angelbroking/order/v1/searchScrip", :post},
    "place_order" => {"rest/secure/angelbroking/order/v1/placeOrder", :post},
    "modify_order" => {"rest/secure/angelbroking/order/v1/modifyOrder", :post},
    "cancel_order" => {"rest/secure/angelbroking/order/v1/cancelOrder", :post},
    "order_status" => {"rest/secure/angelbroking/order/v1/details", :post},
    "verify_dis" => {"rest/secure/angelbroking/edis/v1/verifyDis", :post},
    "estimate_charges" => {"rest/secure/angelbroking/brokerage/v1/estimateCharges", :post}
  }

  setup do
    Application.put_env(:trade_galleon, Broker, @config)

    mocks =
      Enum.map(@routes, fn {name, {path, method}} ->
        """
        %{
          method: :#{method},
          url: "#{@base_url}/#{path}",
        } ->
          response_mod = "#{name}" |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join("")
          %Tesla.Env{
            status: 200,
            body: %{
              "message" => "SUCCESS",
              "data" => ("#{Broker.Responses}" <> "." <> response_mod)
                    |> String.to_existing_atom()
                    |> Map.from_struct()
                    |> Enum.map(fn {k, _} -> {k, "\#\{k\}\"} end)
                    |> Enum.into(%{})
                    |> Jason.encode!()
                    |> Jason.decode!()
            }
          }
        """
      end)

    Code.eval_string("""
      Tesla.Mock.mock(fn
        #{mocks}
      end)
    """)

    :ok
  end
end
