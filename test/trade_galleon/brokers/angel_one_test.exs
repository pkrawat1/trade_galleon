defmodule TradeGalleon.Brokers.AngelOneTest do
  use ExUnit.Case, async: true
  alias TradeGalleon.Brokers.AngelOne, as: Broker
  alias TradeGalleon.Brokers.AngelOne.Responses

  @config [
    api_key: "test_api_key",
    local_ip: "127.0.0.1",
    public_ip: "1.2.3.4",
    mac_address: "00:11:22:33:44:55",
    secret_key: "test_secret_key"
  ]

  setup do
    Application.put_env(:trade_galleon, Broker, @config)
    Tesla.Mock.mock(fn _ -> %Tesla.Env{status: 200, body: %{"message" => "SUCCESS", "data" => %{}}} end)
    %{config: Enum.into(@config, %{})}
  end

  describe "client/1" do
    test "creates Tesla client with correct headers without token", %{config: config} do
      client = Broker.client(config: config)
      # Tesla client in newer versions is a struct, not a list
      assert %Tesla.Client{} = client

      # Extract headers from pre middleware
      headers = get_client_headers(client)

      assert headers["Content-Type"] == "application/json"
      assert headers["X-PrivateKey"] == config.api_key
      assert headers["X-ClientLocalIP"] == config.local_ip
      assert headers["X-ClientPublicIP"] == config.public_ip
      assert headers["X-MACAddress"] == config.mac_address
      refute Map.has_key?(headers, "authorization")
    end

    test "creates Tesla client with correct headers with token", %{config: config} do
      client = Broker.client(config: config, token: "test_token")
      headers = get_client_headers(client)
      assert headers["authorization"] == "Bearer test_token"
    end
  end

  describe "login/1" do
    test "sends correct request and parses response", %{config: config} do
      mock_success_response("login", %{})

      params = %{"client_code" => "test_client", "password" => "test_pass", "totp" => "123456"}
      opts = [params: params, config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => %Responses.Login{}}} = Broker.login(opts)
    end

    test "returns error on invalid credentials", %{config: config} do
      mock_error_response("login", %{"message" => "FAILED", "error" => "Invalid credentials"})

      params = %{"client_code" => "bad_client", "password" => "wrong", "totp" => "000000"}
      opts = [params: params, config: config]

      assert {:error, %{"message" => "FAILED", "error" => "Invalid credentials"}} = Broker.login(opts)
    end

    test "validates request params", %{config: config} do
      # Missing required parameter "totp"
      params = %{"client_code" => "test_client", "password" => "test_pass"}
      opts = [params: params, config: config]

      assert_raise Ecto.ChangeError, fn -> Broker.login(opts) end
    end
  end

  describe "logout/1" do
    test "sends logout request correctly", %{config: config} do
      mock_success_response("logout", %{})

      params = %{"client_code" => "test_client"}
      opts = [params: params, config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => %Responses.Logout{}}} = Broker.logout(opts)
    end
  end

  describe "generate_token/1" do
    test "returns new token on success", %{config: config} do
      mock_success_response("generate_token", %{
        "jwt_token" => "new_jwt_token",
        "refresh_token" => "new_refresh_token",
        "feed_token" => "feed_token"
      })

      params = %{"refresh_token" => "old_refresh_token"}
      opts = [params: params, config: config, token: "current_token"]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.generate_token(opts)
      assert %Responses.GenerateToken{
        jwt_token: "new_jwt_token",
        refresh_token: "new_refresh_token",
        feed_token: "feed_token"
      } = data
    end
  end

  describe "profile/1" do
    test "retrieves user profile with token", %{config: config} do
      mock_success_response("profile", %{
        "client_code" => "TEST01",
        "name" => "Test User",
        "email" => "test@example.com"
      })

      opts = [token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.profile(opts)
      assert %Responses.Profile{
        client_code: "TEST01",
        name: "Test User",
        email: "test@example.com"
      } = data
    end
  end

  describe "portfolio/1" do
    test "retrieves portfolio holdings", %{config: config} do
      mock_success_response("portfolio", %{
        "holdings" => [
          %{"tradingsymbol" => "SBIN-EQ", "exchange" => "NSE", "quantity" => 10}
        ]
      })

      opts = [token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.portfolio(opts)
      assert %Responses.Portfolio{} = data
    end
  end

  describe "quote/1" do
    test "retrieves market quotes", %{config: config} do
      mock_success_response("quote", %{
        "NSE:22" => %{
          "tradingsymbol" => "SBIN-EQ",
          "ltp" => 350.45,
          "open" => 345.2
        }
      })

      params = %{"mode" => "FULL", "exchange_tokens" => %{"NSE" => ["22"]}}
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.quote(opts)
      assert %Responses.Quote{} = data
    end
  end

  describe "candle_data/1" do
    test "retrieves historical candle data", %{config: config} do
      mock_success_response("candle_data", %{
        "data" => [
          ["2021-01-01T09:15:00+05:30", 350.45, 352.3, 348.7, 350.0, 1050]
        ]
      })

      params = %{
        "exchange" => "NSE",
        "symbol_token" => "22",
        "interval" => "ONE_MINUTE",
        "from_date" => "2021-01-01 11:15",
        "to_date" => "2021-01-01 15:30"
      }
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => %Responses.CandleData{data: data}}} = Broker.candle_data(opts)
      assert is_list(data)
      assert length(data) == 1
    end
  end

  describe "funds/1" do
    test "retrieves user funds", %{config: config} do
      mock_success_response("funds", %{
        # Ensure fields match what the schema expects
        "availablecash" => "10000.50",
        "net" => "15000.75"
      })

      opts = [token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.funds(opts)
      assert %Responses.Funds{} = data
    end
  end

  describe "order_book/1" do
    test "retrieves order book", %{config: config} do
      mock_success_response("order_book", %{
        "data" => [
          %{"orderid" => "123456", "tradingsymbol" => "SBIN-EQ", "status" => "COMPLETE"}
        ]
      })

      opts = [token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.order_book(opts)
      assert %Responses.OrderBook{} = data
    end
  end

  describe "trade_book/1" do
    test "retrieves trade book", %{config: config} do
      mock_success_response("trade_book", %{
        "data" => [
          %{"tradeid" => "T123", "orderid" => "123456", "tradingsymbol" => "SBIN-EQ"}
        ]
      })

      opts = [token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.trade_book(opts)
      assert %Responses.TradeBook{} = data
    end
  end

  describe "search_token/1" do
    test "searches for script tokens", %{config: config} do
      mock_success_response("search_token", %{
        "data" => [
          %{"token" => "3045", "tradingsymbol" => "SBIN-EQ", "exchange" => "NSE"}
        ]
      })

      params = %{"exchange" => "NSE", "search_scrip" => "SBIN"}
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.search_token(opts)
      assert %Responses.SearchToken{} = data
    end
  end

  describe "place_order/1" do
    test "places a limit order", %{config: config} do
      mock_success_response("place_order", %{"order_id" => "12345678"})

      params = %{
        "variety" => "NORMAL",
        "trading_symbol" => "SBIN-EQ",
        "symbol_token" => "3045",
        "transaction_type" => "BUY",
        "exchange" => "NSE",
        "order_type" => "LIMIT",
        "product_type" => "INTRADAY",
        "duration" => "DAY",
        "price" => "200",
        "quantity" => "1"
      }
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.place_order(opts)
      assert %Responses.PlaceOrder{order_id: "12345678"} = data
    end

    test "places a stoploss order", %{config: config} do
      mock_success_response("place_order", %{"order_id" => "87654321"})

      params = %{
        "variety" => "NORMAL",
        "trading_symbol" => "SBIN-EQ",
        "symbol_token" => "3045",
        "transaction_type" => "BUY",
        "exchange" => "NSE",
        "order_type" => "STOPLOSS_LIMIT",
        "trigger_price" => "200",
        "product_type" => "INTRADAY",
        "duration" => "DAY",
        "price" => "200",
        "quantity" => "1"
      }
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.place_order(opts)
      assert %Responses.PlaceOrder{order_id: "87654321"} = data
    end
  end

  describe "modify_order/1" do
    test "modifies an existing order", %{config: config} do
      mock_success_response("modify_order", %{"order_id" => "12345678"})

      params = %{
        "variety" => "NORMAL",
        "order_id" => "12345678",
        "transaction_type" => "BUY",
        "exchange" => "NSE",
        "order_type" => "LIMIT",
        "product_type" => "INTRADAY",
        "duration" => "DAY",
        "price" => "210",
        "quantity" => "2"
      }
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.modify_order(opts)
      assert %Responses.ModifyOrder{order_id: "12345678"} = data
    end
  end

  describe "cancel_order/1" do
    test "cancels an order", %{config: config} do
      mock_success_response("cancel_order", %{"order_id" => "12345678"})

      params = %{"variety" => "NORMAL", "order_id" => "12345678"}
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.cancel_order(opts)
      assert %Responses.CancelOrder{order_id: "12345678"} = data
    end
  end

  describe "order_status/1" do
    test "retrieves order status", %{config: config} do
      # Set up specific mock for order_status
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://apiconnect.angelbroking.com/rest/secure/angelbroking/order/v1/details/uniqueorder_id"} ->
          %Tesla.Env{
            status: 200,
            body: %{
              "message" => "SUCCESS",
              "data" => %{
                "orderid" => "12345678",
                "status" => "COMPLETE",
                "uniqueorderid" => "uniqueorder_id"
              }
            }
          }
      end)

      # The key is "unique_order_id" in the request but comes back as "uniqueorderid" in the response
      params = %{"unique_order_id" => "uniqueorder_id"}
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.order_status(opts)
      assert %Responses.OrderStatus{} = data
    end
  end

  describe "verify_dis/1" do
    test "verifies DIS", %{config: config} do
      mock_success_response("verify_dis", %{"status" => "APPROVED"})

      params = %{"isin" => "INE000A01010", "quantity" => "1"}
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.verify_dis(opts)
      assert %Responses.VerifyDis{} = data
    end
  end

  describe "estimate_charges/1" do
    test "estimates transaction charges", %{config: config} do
      mock_success_response("estimate_charges", %{
        "chargesBreakup" => %{
          "brokerage" => 20.0,
          "transactionTax" => 5.0
        },
        "totalCharges" => 25.0
      })

      params = %{
        "orders" => [
          %{
            "symbol_name" => "SBIN-EQ",
            "token" => "3045",
            "transaction_type" => "BUY",
            "exchange" => "NSE",
            "product_type" => "INTRADAY",
            "price" => "200",
            "quantity" => "1"
          }
        ]
      }
      opts = [params: params, token: "test_token", config: config]

      assert {:ok, %{"message" => "SUCCESS", "data" => data}} = Broker.estimate_charges(opts)
      assert %Responses.EstimateCharges{} = data
    end
  end

  describe "error handling" do
    test "handles non-success responses", %{config: config} do
      mock_error_response("profile", %{"message" => "FAILED", "error" => "Session expired"})

      opts = [token: "expired_token", config: config]
      assert {:error, %{"message" => "FAILED", "error" => "Session expired"}} = Broker.profile(opts)
    end

    test "handles network errors", %{config: config} do
      Tesla.Mock.mock(fn
        %{method: :get, url: "https://apiconnect.angelbroking.com/rest/secure/angelbroking/user/v1/getProfile"} ->
          {:error, :timeout}
      end)

      opts = [token: "test_token", config: config]
      assert {:error, %{"message" => _}} = Broker.profile(opts)
    end
  end

  # Helper functions
  defp mock_success_response(endpoint, data) do
    {path, method} = get_endpoint_details(endpoint)

    Tesla.Mock.mock(fn
      %{method: ^method, url: url} ->
        if String.starts_with?(url, "https://apiconnect.angelbroking.com/#{path}") do
          %Tesla.Env{
            status: 200,
            body: %{
              "message" => "SUCCESS",
              "data" => data
            }
          }
        else
          {:error, :unexpected_url}
        end
    end)
  end

  defp mock_error_response(endpoint, error_data) do
    {path, method} = get_endpoint_details(endpoint)

    Tesla.Mock.mock(fn
      %{method: ^method, url: url} ->
        if String.starts_with?(url, "https://apiconnect.angelbroking.com/#{path}") do
          %Tesla.Env{
            status: error_data["status"] || 400,
            body: error_data
          }
        else
          {:error, :unexpected_url}
        end
    end)
  end

  defp get_endpoint_details(endpoint) do
    case endpoint do
      "login" -> {"rest/auth/angelbroking/user/v1/loginByPassword", :post}
      "logout" -> {"rest/secure/angelbroking/user/v1/logout", :post}
      "generate_token" -> {"rest/auth/angelbroking/jwt/v1/generateTokens", :post}
      "profile" -> {"rest/secure/angelbroking/user/v1/getProfile", :get}
      "portfolio" -> {"rest/secure/angelbroking/portfolio/v1/getHolding", :get}
      "quote" -> {"rest/secure/angelbroking/market/v1/quote", :post}
      "candle_data" -> {"rest/secure/angelbroking/historical/v1/getCandleData", :post}
      "funds" -> {"rest/secure/angelbroking/user/v1/getRMS", :get}
      "order_book" -> {"rest/secure/angelbroking/order/v1/getOrderBook", :get}
      "trade_book" -> {"rest/secure/angelbroking/order/v1/getTradeBook", :get}
      "search_token" -> {"rest/secure/angelbroking/order/v1/searchScrip", :post}
      "place_order" -> {"rest/secure/angelbroking/order/v1/placeOrder", :post}
      "modify_order" -> {"rest/secure/angelbroking/order/v1/modifyOrder", :post}
      "cancel_order" -> {"rest/secure/angelbroking/order/v1/cancelOrder", :post}
      "verify_dis" -> {"rest/secure/angelbroking/edis/v1/verifyDis", :post}
      "estimate_charges" -> {"rest/secure/angelbroking/brokerage/v1/estimateCharges", :post}
    end
  end

  defp get_client_headers(client) do
    # Extract headers from Tesla client struct
    client.pre
    |> Enum.find_value(%{}, fn
      {Tesla.Middleware.Headers, :call, [headers]} ->
        Map.new(headers, fn {key, value} -> {key, value} end)
      _ ->
        false
    end)
  end
end
