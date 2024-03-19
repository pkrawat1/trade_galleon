defmodule TradeGalleon.Brokers.AngelOneTest do
  use ExUnit.Case
  doctest TradeGalleon.Brokers.AngelOne
  import Tesla.Mock
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
    login: "rest/auth/angelbroking/user/v1/loginByPassword",
    logout: "rest/secure/angelbroking/user/v1/logout",
    generate_token: "rest/auth/angelbroking/jwt/v1/generateTokens",
    profile: "rest/secure/angelbroking/user/v1/getProfile",
    portfolio: "rest/secure/angelbroking/portfolio/v1/getHolding",
    quote: "rest/secure/angelbroking/market/v1/quote",
    candle_data: "rest/secure/angelbroking/historical/v1/getCandleData",
    funds: "rest/secure/angelbroking/user/v1/getRMS",
    order_book: "/rest/secure/angelbroking/order/v1/getOrderBook",
    trade_book: "rest/secure/angelbroking/order/v1/getTradeBook",
    search_token: "rest/secure/angelbroking/order/v1/searchScrip",
    place_order: "rest/secure/angelbroking/order/v1/placeOrder",
    modify_order: "rest/secure/angelbroking/order/v1/modifyOrder",
    cancelOrder: "rest/secure/angelbroking/order/v1/cancelOrder",
    orderStatus: "rest/secure/angelbroking/order/v1/details",
    verifyDis: "rest/secure/angelbroking/edis/v1/verifyDis",
    estimateCharges: "rest/secure/angelbroking/brokerage/v1/estimateCharges"
  }

  setup do
    Application.put_env(:trade_galleon, Broker, @config)

    quote(
      Enum.each(@routes, fn {name, url} ->
        Tesla.Mock.mock(fn
          %{
            method: :post,
            url: unquote(@base_url <> "/" <> url)
          } ->
            response_mod =
              name |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join()

            %Tesla.Env{
              status: 200,
              body: %{
                "message" => "SUCCESS",
                "data" =>
                  ("Broker.Responses" <> response_mod)
                  |> String.to_existing_atom()
                  |> Map.from_struct()
              }
            }
        end)
      end)
    )

    :ok
  end

  test "API Failure" do
    Tesla.Mock.mock(fn
      %{method: :post} -> {:error, %{body: "API ERROR"}}
    end)

    assert {:error, body} =
             TradeGalleon.call(Broker, :login)

    assert body["message"] == "API ERROR"
  end

  describe "authentication" do
    test "Login Success" do
      resp = %{
        "status" => true,
        "message" => "SUCCESS",
        "errorcode" => "",
        "data" => %{
          "jwtToken" => "token",
          "refreshToken" => "token",
          "feedToken" => "token"
        }
      }

      Tesla.Mock.mock(fn
        %{method: :post} -> json(resp)
      end)

      assert {:ok, body} =
               TradeGalleon.call(Broker, :login, params: %{"password" => "", "totp" => ""})

      assert body["message"] == "SUCCESS"
      assert body["data"] == resp["data"]
    end

    test "Login Failure" do
      resp = %{
        "data" => nil,
        "errorcode" => "AB1048",
        "message" => "Invalid clientcode parameter name",
        "status" => false
      }

      Tesla.Mock.mock(fn
        %{method: :post} -> json(resp)
      end)

      assert {:error, body} =
               TradeGalleon.call(Broker, :login,
                 params: %{"clientcode" => "", "password" => "", "totp" => ""}
               )

      assert body["message"] == resp["message"]
    end

    test "Logout" do
      resp = %{
        "status" => true,
        "message" => "SUCCESS",
        "errorcode" => "",
        "data" => nil
      }

      Tesla.Mock.mock(fn
        %{method: :post} -> json(resp)
      end)

      assert {:ok, body} =
               TradeGalleon.call(Broker, :logout, params: %{"clientcode" => ""})

      assert body["message"] == "SUCCESS"
    end
  end
end
