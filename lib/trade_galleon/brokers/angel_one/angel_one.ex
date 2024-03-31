defmodule TradeGalleon.Brokers.AngelOne do
  @moduledoc """
  AngelOne Broker Module to interact with AngelOne API
  """
  use TradeGalleon.Adapter,
    required_config: [:api_key, :local_ip, :public_ip, :mac_address, :secret_key]

  alias TradeGalleon.Brokers.AngelOne.{Requests, Responses}

  @behaviour TradeGalleon.Broker

  @base_url "https://apiconnect.angelbroking.com"
  @routes %{
    socket: "ws://smartapisocket.angelone.in/smart-stream",
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
    cancel_order: "rest/secure/angelbroking/order/v1/cancelOrder",
    order_status: "rest/secure/angelbroking/order/v1/details",
    verify_dis: "rest/secure/angelbroking/edis/v1/verifyDis",
    estimate_charges: "rest/secure/angelbroking/brokerage/v1/estimateCharges"
  }

  @doc """
  Login to AngelOne API

  ## Example

  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :login, params: %{"client_code" => "client_code", "password" => "1234", "totp" => "123456"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Login{}}}
  """
  def login(opts) do
    opts = validate_request(opts, Requests.Login)

    opts
    |> client()
    |> post(@routes.login, opts[:params])
    |> gen_response(Responses.Login)
  end

  @doc """
  Logout from AngelOne API

  Example

  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :logout, params: %{"client_code" => "client_code"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Logout{}}}
  """
  def logout(opts) do
    opts = validate_request(opts, Requests.Logout)

    opts
    |> client()
    |> post(@routes.logout, opts[:params])
    |> gen_response(Responses.Logout)
  end

  @doc """
  Generate Token from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :generate_token, token: "token", params: %{"refresh_token" => "refresh_token"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.GenerateToken{}}}
  """
  def generate_token(opts) do
    opts = validate_request(opts, Requests.GenerateToken)

    opts
    |> client()
    |> post(@routes.generate_token, opts[:params])
    |> gen_response(Responses.GenerateToken)
  end

  @doc """
  Get Profile from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :profile, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Profile{}}}
  """
  def profile(opts) do
    opts = validate_request(opts, Requests.Profile)

    opts
    |> client()
    |> get(@routes.profile)
    |> gen_response(Responses.Profile)
  end

  @doc """
  Get Portfolio from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :portfolio, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Portfolio{}}}
  """
  def portfolio(opts) do
    opts = validate_request(opts, Requests.Portfolio)

    opts
    |> client()
    |> get(@routes.portfolio)
    |> gen_response(Responses.Portfolio)
  end

  @doc """
  Get Quote from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/MarketData

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :quote, token: "token", params: %{"mode" => "FULL", "exchange_tokens" => %{"NSE" => ["22"]}})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Quote{}}}
  """
  def quote(opts) do
    opts = validate_request(opts, Requests.Quote)

    opts
    |> client()
    |> post(@routes.quote, opts[:params])
    |> gen_response(Responses.Quote)
  end

  @doc """
  Get Candle Data from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Historical

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :candle_data, token: "token", params: %{"exchange" => "NSE", "symbol_token" => "22", "interval" => "ONE_MINUTE", "from_date" => "2021-01-01 11:15", "to_date" => "2021-01-01 15:30"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.CandleData{}}}
  """
  def candle_data(opts) do
    opts = validate_request(opts, Requests.CandleData)

    opts
    |> client()
    |> post(@routes.candle_data, opts[:params])
    |> gen_response(Responses.CandleData)
  end

  @doc """
  Get Profile Funds from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :funds, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Funds{}}}
  """
  def funds(opts) do
    opts = validate_request(opts, Requests.Funds)

    opts
    |> client()
    |> get(@routes.funds)
    |> gen_response(Responses.Funds)
  end

  @doc """
  Get Order Book from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :order_book, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.OrderBook{}}}
  """
  def order_book(opts) do
    opts = validate_request(opts, Requests.OrderBook)

    opts
    |> client()
    |> get(@routes.order_book)
    |> gen_response(Responses.OrderBook)
  end

  @doc """
  Get Trade Book from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :trade_book, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.TradeBook{}}}
  """
  def trade_book(opts) do
    opts = validate_request(opts, Requests.TradeBook)

    opts
    |> client()
    |> get(@routes.trade_book)
    |> gen_response(Responses.TradeBook)
  end

  @doc """
  Search Token from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :search_token, token: "token", params: %{"exchange" => "NSE", "search_scrip" => "SBIN"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.SearchToken{}}}
  """
  def search_token(opts) do
    opts = validate_request(opts, Requests.SearchToken)

    opts
    |> client()
    |> post(@routes.search_token, opts[:params])
    |> gen_response(Responses.SearchToken)
  end

  @doc """
  Place Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#place

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :place_order, token: "token", params: %{"variety" => "NORMAL", "trading_symbol" => "SBIN-EQ", "symbol_token" => "3045", "transaction_type" => "BUY", "exchange" => "NSE", "order_type" => "LIMIT", "product_type" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.PlaceOrder{}}}
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :place_order, token: "token", params: %{"variety" => "NORMAL", "trading_symbol" => "SBIN-EQ", "symbol_token" => "3045", "transaction_type" => "BUY", "exchange" => "NSE", "order_type" => "STOPLOSS_LIMIT", "trigger_price" => "200", "product_type" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.PlaceOrder{}}}
  """
  def place_order(opts) do
    opts = validate_request(opts, Requests.PlaceOrder)

    opts
    |> client()
    |> post(@routes.place_order, opts[:params])
    |> gen_response(Responses.PlaceOrder)
  end

  @doc """
  Modify Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#modifyorder

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :modify_order, token: "token", params: %{"variety" => "NORMAL", "order_id" => "order_id", "transaction_type" => "BUY", "exchange" => "NSE", "order_type" => "LIMIT", "product_type" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.ModifyOrder{}}}
  """
  def modify_order(opts) do
    opts = validate_request(opts, Requests.ModifyOrder)

    opts
    |> client()
    |> post(@routes.modify_order, opts[:params])
    |> gen_response(Responses.ModifyOrder)
  end

  @doc """
  Cancel Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#cancelorder

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :cancel_order, token: "token", params: %{"variety" => "NORMAL", "order_id" => "order_id"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.CancelOrder{}}}
  """
  def cancel_order(opts) do
    opts = validate_request(opts, Requests.CancelOrder)

    opts
    |> client()
    |> post(@routes.cancel_order, opts[:params])
    |> gen_response(Responses.CancelOrder)
  end

  @doc """
  Order Status from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#indorder

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :order_status, token: "token", params: %{"unique_order_id" => "uniqueorder_id"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.OrderStatus{}}}
  """
  def order_status(opts) do
    opts = validate_request(opts, Requests.OrderStatus)

    opts
    |> client()
    |> get(@routes.order_status, query: opts[:params])
    |> gen_response(Responses.OrderStatus)
  end

  @doc """
  Verify DIS from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :verify_dis, token: "token", params: %{"isin" => "isin", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.VerifyDis{}}}
  """
  def verify_dis(opts) do
    opts = validate_request(opts, Requests.VerifyDis)

    opts
    |> client()
    |> post(@routes.verify_dis, opts[:params])
    |> gen_response(Responses.VerifyDis)
  end

  @doc """
  Estimate Charges for order from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :estimate_charges, token: "token", params: %{"orders" => [%{"symbol_name" => "SBIN-EQ", "token" => "3045", "transaction_type" => "BUY", "exchange" => "NSE",  "product_type" => "INTRADAY", "price" => "200", "quantity" => "1"}]})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.EstimateCharges{}}}
  """
  def estimate_charges(opts) do
    opts = validate_request(opts, Requests.EstimateCharges)

    opts
    |> client()
    |> post(@routes.estimate_charges, opts[:params])
    |> gen_response(Responses.EstimateCharges)
  end

  @impl TradeGalleon.Broker
  def client(opts) do
    config = opts[:config]

    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"X-UserType", "USER"},
      {"X-SourceID", "WEB"},
      {"X-ClientLocalIP", config[:local_ip]},
      {"X-ClientPublicIP", config[:public_ip]},
      {"X-MACAddress", config[:mac_address]},
      {"X-PrivateKey", config[:api_key]}
    ]

    headers =
      if opts[:token] do
        [{"authorization", "Bearer " <> opts[:token]} | headers]
      else
        headers
      end

    middleware = [
      {Tesla.Middleware.BaseUrl, @base_url},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Headers, headers},
      {Tesla.Middleware.Retry,
       delay: 1000,
       max_retries: 3,
       max_delay: 4_000,
       should_retry: fn
         {:ok, %{status: status}} when status in [400, 403, 500] -> true
         {:ok, _} -> false
         {:error, _} -> true
       end}
    ]

    Tesla.client(middleware)
  end

  defp gen_response({:ok, %{body: %{"message" => message} = body} = _env}, module)
       when message == "SUCCESS" do
    {:ok, %{body | "data" => validate_response(body["data"], module)}}
  end

  defp gen_response({:ok, %{body: body} = _env}, _module) do
    {:error, body}
  end

  defp gen_response({:error, %{body: body}}, _module) when is_binary(body),
    do: {:error, %{"message" => body}}

  defp gen_response({:error, %{body: body}}, _module), do: {:error, body}

  defp validate_request(opts, module) do
    case module.to_schema(opts[:params] || %{}) do
      {:ok, module_struct} ->
        Keyword.put(opts, :params, module_struct |> Jason.encode!() |> Jason.decode!())

      {:error, changeset} ->
        raise Ecto.ChangeError, inspect({:error, changeset.errors})
    end
  end

  defp validate_response(response, module) do
    case module.to_schema(response || %{}) do
      {:ok, response} -> response
      {:error, changeset} -> raise Ecto.ChangeError, inspect({:error, changeset.errors})
    end
  end
end
