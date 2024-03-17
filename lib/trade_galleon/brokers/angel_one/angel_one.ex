defmodule TradeGalleon.Brokers.AngelOne do
  @moduledoc """
  AngelOne Broker Module to interact with AngelOne API
  """
  use TradeGalleon.Adapter,
    required_config: [:api_key, :local_ip, :public_ip, :mac_address, :secret_key]

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

  iex> TradeGalleon.call(AngelOne, :login, params: %{"clientcode" => "client_code", "password" => "pin", "totp" => "code displayed in authenticator app"})
      {:ok, %{"message" => "SUCCESS", "data" => %{"jwtToken" => "token", "refreshToken" => "refresh_token", "feedToken" => "feed_token"}}} | {:error, %{"message" => "error message"}}
  """
  def login(opts) do
    opts
    |> client()
    |> post(@routes.login, opts[:params])
    |> gen_response()
  end

  @doc """
  Logout from AngelOne API

  ## Example

  iex> TradeGalleon.call(AngelOne, :logout, params: %{"clientcode" => "client_code"})
      {:ok, %{"message" => "SUCCESS"}} | {:error, %{"message" => "error message"}}
  """
  def logout(opts) do
    opts
    |> client()
    |> post(@routes.logout, opts[:params])
    |> gen_response()
  end

  @doc """
  Generate Token from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :generate_token, token: "token", params: %{"refreshToken" => "refresh_token"})
      {:ok, %{"message" => "SUCCESS", "data" => %{"jwtToken" => "token", "refreshToken" => "refresh_token", "feedToken" => "feed_token"}}} | {:error, %{"message" => "error message"}}
  """
  def generate_token(opts) do
    opts
    |> client()
    |> post(@routes.generate_token, opts[:params])
    |> gen_response()
  end

  @doc """
  Get Profile from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :profile, token: "token")
      {:ok, %{"message" => "SUCCESS", "data" => %{"clientcode" => "client_code", "name" => "name", "email" => "email", "mobileno" => "mobile", "exchanges" => "exchanges" ... etc}}} | {:error, %{"message" => "error message"}}
  """
  def profile(opts) do
    opts
    |> client()
    |> get(@routes.profile)
    |> gen_response()
  end

  @doc """
  Get Portfolio from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :portfolio, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %{holdings" => [%{...}...], "totalholding" => %{...} ... etc}}} | {:error, %{"message" => "error message"}}
  """
  def portfolio(opts) do
    opts
    |> client()
    |> get(@routes.portfolio)
    |> gen_response()
  end

  @doc """
  Get Quote from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/MarketData

  ## Example
  iex> TradeGalleon.call(AngelOne, :quote, token: "token", params: %{"mode" => "full", "exchangeTokens" => %{"NSE" => ["22"]}})
  {:ok, %{"message" => "SUCCESS", "data" => %{"fetched" => [%{...}...], ... etc}}} | {:error, %{"message" => "error message"}}
  """
  def quote(opts) do
    opts
    |> client()
    |> post(@routes.quote, opts[:params])
    |> gen_response()
  end

  @doc """
  Get Candle Data from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Historical 

  ## Example
  iex> TradeGalleon.call(AngelOne, :candle_data, token: "token", params: %{"exchange" => "NSE", "symboltoken" => "22", "interval" => "ONE_MINUTE", "fromdate" => "2021-01-01 11:15", "todate" => "2021-01-01 15:30"})
  {:ok, %{"message" => "SUCCESS", "data" => [[...]]} | {:error, %{"message" => "error message"}}
  """
  def candle_data(opts) do
    opts
    |> client()
    |> post(@routes.candle_data, opts[:params])
    |> gen_response()
  end

  @doc """
  Get Profile Funds from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :funds, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => %{"net" => "99999", "availablecash" => "12345", ... etc}}} | {:error, %{"message" => "error message"}}
  """
  def funds(opts) do
    opts
    |> client()
    |> get(@routes.funds)
    |> gen_response()
  end

  @doc """
  Get Order Book from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :order_book, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => [%{order...}, ...]} | {:error, %{"message" => "error message"}}
  """
  def order_book(opts) do
    opts
    |> client()
    |> get(@routes.order_book)
    |> gen_response()
  end

  @doc """
  Get Trade Book from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :trade_book, token: "token")
  {:ok, %{"message" => "SUCCESS", "data" => [%{trade...}, ...]} | {:error, %{"message" => "error message"}}
  """
  def trade_book(opts) do
    opts
    |> client()
    |> get(@routes.trade_book)
    |> gen_response()
  end

  @doc """
  Search Token from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :search_token, token: token, params: %{"exchange" => "NSE", "searchscrip" => "SBIN"})
  {:ok, %{"message" => "SUCCESS", "data" => [%{"exchange" => "NSE", "symbol" => "SBIN", "name" => "State Bank of India", "token" => "3045"}, ...etc]} | {:error, %{"message" => "error message"}}
  """
  def search_token(opts) do
    opts
    |> client()
    |> post(@routes.search_token, opts[:params])
    |> gen_response()
  end

  @doc """
  Place Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#place

  ## Example
  iex> TradeGalleon.call(AngelOne, :place_order, token: token, params: %{"variety" => "NORMAL", "tradingsymbol" => "SBIN-EQ", "symboltoken" => "3045", "transactiontype" => "BUY", "exchange" => "NSE", "ordertype" => "LIMIT", "producttype" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %{"script" => "SBIN-EQ", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}} | {:error, %{"message" => "error message"}}
  """
  def place_order(opts) do
    opts
    |> client()
    |> post(@routes.place_order, opts[:params])
    |> gen_response()
  end

  @doc """
  Modify Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#modifyorder

  ## Example
  iex> TradeGalleon.call(AngelOne, :modify_order, token: token, params: %{"variety" => "NORMAL", "orderid" => "orderid", "transactiontype" => "BUY", "exchange" => "NSE", "ordertype" => "LIMIT", "producttype" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %{"script" => "SBIN-EQ", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}} | {:error, %{"message" => "error message"}}
  """
  def modify_order(opts) do
    opts
    |> client()
    |> post(@routes.modify_order, opts[:params])
    |> gen_response()
  end

  @doc """
  Cancel Order from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#cancelorder

  ## Example
  iex> TradeGalleon.call(AngelOne, :cancel_order, token: token, params: %{"variety" => "NORMAL", "orderid" => "orderid"})
  {:ok, %{"message" => "SUCCESS", "data" => %{"orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}} | {:error, %{"message" => "error message"}}
  """
  def cancel_order(opts) do
    opts
    |> client()
    |> post(@routes.cancel_order, opts[:params])
    |> gen_response()
  end

  @doc """
  Order Status from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/Orders#indorder

  ## Example
  iex> TradeGalleon.call(AngelOne, :order_status, token: token, params: %{"unique_order_id" => "uniqueorderid"})
  {:ok, %{"message" => "SUCCESS", "data" => %{"status" => "completed", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid", ...etc}} | {:error, %{"message" => "error message"}}
  """
  def order_status(opts) do
    opts
    |> client()
    |> get(@routes.order_status <> "/" <> opts[:params]["unique_order_id"])
    |> gen_response()
  end

  @doc """
  Verify DIS from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :verify_dis, token: token, params: %{"isin" => "isin", "quantity" => "1"})
  {:ok, %{"message" => "SUCCESS", "data" => %{...}} | {:error, %{"message" => "error message"}}
  """
  def verify_dis(opts) do
    opts
    |> client()
    |> post(@routes.verify_dis, opts[:params])
    |> gen_response()
  end

  @doc """
  Estimate Charges for order from AngelOne API

  ## Example
  iex> TradeGalleon.call(AngelOne, :estimate_charges, token: token, params: %{"orders" => [%{"symbol_name" => "SBIN-EQ", "token" => "3045", "transaction_type" => "BUY", "exchange" => "NSE",  "product_type" => "INTRADAY", "price" => "200", "quantity" => "1"}]})
  {:ok, %{"message" => "SUCCESS", "data" => %{...}} | {:error, %{"message" => "error message"}}
  """
  def estimate_charges(opts) do
    opts
    |> client()
    |> post(@routes.estimate_charges, opts[:params])
    |> gen_response()
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

  defp gen_response({:ok, %{body: %{"message" => message} = body} = _env})
       when message == "SUCCESS" do
    # IO.inspect(_env)
    {:ok, body}
  end

  defp gen_response({:ok, %{body: body} = _env}) do
    # IO.inspect(_env)
    {:error, body}
  end

  defp gen_response({:error, %{body: body}}) when is_binary(body),
    do: {:error, %{"message" => body}}

  defp gen_response({:error, %{body: body}}), do: {:error, body}
end
