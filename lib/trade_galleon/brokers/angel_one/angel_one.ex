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

  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :login, params: %{"clientcode" => "client_code", "password" => "pin", "totp" => "code displayed in authenticator app"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Login{} }}
  """
  def login(opts) do
    opts
    |> validate_params(Requests.Login)
    |> client()
    |> post(@routes.login, opts[:params])
    |> gen_response(Responses.Login)
  end

  @doc """
  Logout from AngelOne API

  ## Example

  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :logout, params: %{"clientcode" => "client_code"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Logout{}}}
  """
  def logout(opts) do
    opts
    |> validate_params(Requests.Logout)
    |> client()
    |> post(@routes.logout, opts[:params])
    |> gen_response(Responses.Logout)
  end

  @doc """
  Generate Token from AngelOne API

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :generate_token, token: "token", params: %{"refreshToken" => "refresh_token"})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.GenerateToken{}}}
  """
  def generate_token(opts) do
    opts
    |> validate_params(Requests.GenerateToken)
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
    opts
    |> validate_params(Requests.Profile)
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
    opts
    |> validate_params(Requests.Profile)
    |> client()
    |> get(@routes.portfolio)
    |> gen_response(Responses.Portfolio)
  end

  @doc """
  Get Quote from AngelOne API
  doc: https://smartapi.angelbroking.com/docs/MarketData

  Example
  iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :quote, token: "token", params: %{"mode" => "full", "exchangeTokens" => %{"NSE" => ["22"]}})
  {:ok, %{"message" => "SUCCESS", "data" => %TradeGalleon.Brokers.AngelOne.Responses.Quote{}}}
  """
  def quote(opts) do
    opts
    |> validate_params(Requests.Quote)
    |> client()
    |> post(@routes.quote, opts[:params])
    |> gen_response(Responses.Quote)
  end

  #
  # @doc """
  # Get Candle Data from AngelOne API
  # doc: https://smartapi.angelbroking.com/docs/Historical
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :candle_data, token: "token", params: %{"exchange" => "NSE", "symboltoken" => "22", "interval" => "ONE_MINUTE", "fromdate" => "2021-01-01 11:15", "todate" => "2021-01-01 15:30"})
  # {:ok, %{"message" => "SUCCESS", "data" => [[...]]}
  # """
  # def candle_data(opts) do
  # opts
  # |> client()
  # |> post(@routes.candle_data, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Get Profile Funds from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :funds, token: "token")
  # {:ok, %{"message" => "SUCCESS", "data" => %{"net" => "99999", "availablecash" => "12345"}}}
  # """
  # def funds(opts) do
  # opts
  # |> client()
  # |> get(@routes.funds)
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Get Order Book from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :order_book, token: "token")
  # {:ok, %{"message" => "SUCCESS", "data" => [%{order...}, ...]}
  # """
  # def order_book(opts) do
  # opts
  # |> client()
  # |> get(@routes.order_book)
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Get Trade Book from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :trade_book, token: "token")
  # {:ok, %{"message" => "SUCCESS", "data" => [%{trade...}, ...]}
  # """
  # def trade_book(opts) do
  # opts
  # |> client()
  # |> get(@routes.trade_book)
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Search Token from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :search_token, token: "token", params: %{"exchange" => "NSE", "searchscrip" => "SBIN"})
  # {:ok, %{"message" => "SUCCESS", "data" => [%{"exchange" => "NSE", "symbol" => "SBIN", "name" => "State Bank of India", "token" => "3045"}, ...etc]}
  # """
  # def search_token(opts) do
  # opts
  # |> client()
  # |> post(@routes.search_token, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Place Order from AngelOne API
  # doc: https://smartapi.angelbroking.com/docs/Orders#place
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :place_order, token: "token", params: %{"variety" => "NORMAL", "tradingsymbol" => "SBIN-EQ", "symboltoken" => "3045", "transactiontype" => "BUY", "exchange" => "NSE", "ordertype" => "LIMIT", "producttype" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  # {:ok, %{"message" => "SUCCESS", "data" => %{"script" => "SBIN-EQ", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}}
  # """
  # def place_order(opts) do
  # opts
  # |> client()
  # |> post(@routes.place_order, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Modify Order from AngelOne API
  # doc: https://smartapi.angelbroking.com/docs/Orders#modifyorder
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :modify_order, token: "token", params: %{"variety" => "NORMAL", "orderid" => "orderid", "transactiontype" => "BUY", "exchange" => "NSE", "ordertype" => "LIMIT", "producttype" => "INTRADAY", "duration" => "DAY", "price" => "200", "quantity" => "1"})
  # {:ok, %{"message" => "SUCCESS", "data" => %{"script" => "SBIN-EQ", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}}
  # """
  # def modify_order(opts) do
  # opts
  # |> client()
  # |> post(@routes.modify_order, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Cancel Order from AngelOne API
  # doc: https://smartapi.angelbroking.com/docs/Orders#cancelorder
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :cancel_order, token: "token", params: %{"variety" => "NORMAL", "orderid" => "orderid"})
  # {:ok, %{"message" => "SUCCESS", "data" => %{"orderid" => "orderid", "uniqueorderid" => "uniqueorderid"}}
  # """
  # def cancel_order(opts) do
  # opts
  # |> client()
  # |> post(@routes.cancel_order, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Order Status from AngelOne API
  # doc: https://smartapi.angelbroking.com/docs/Orders#indorder
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :order_status, token: "token", params: %{"unique_order_id" => "uniqueorderid"})
  # {:ok, %{"message" => "SUCCESS", "data" => %{"status" => "completed", "orderid" => "orderid", "uniqueorderid" => "uniqueorderid", ...etc}}
  # """
  # def order_status(opts) do
  # opts
  # |> client()
  # |> get(@routes.order_status <> "/" <> opts[:params]["unique_order_id"])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Verify DIS from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :verify_dis, token: "token", params: %{"isin" => "isin", "quantity" => "1"})
  # {:ok, %{"message" => "SUCCESS", "data" => %{...}}
  # """
  # def verify_dis(opts) do
  # opts
  # |> client()
  # |> post(@routes.verify_dis, opts[:params])
  # |> gen_response(Responses.Login)
  # end
  #
  # @doc """
  # Estimate Charges for order from AngelOne API
  #
  # Example
  # iex> TradeGalleon.call(TradeGalleon.Brokers.AngelOne, :estimate_charges, token: "token", params: %{"orders" => [%{"symbol_name" => "SBIN-EQ", "token" => "3045", "transaction_type" => "BUY", "exchange" => "NSE",  "product_type" => "INTRADAY", "price" => "200", "quantity" => "1"}]})
  # {:ok, %{"message" => "SUCCESS", "data" => %{...}}
  # """
  # def estimate_charges(opts) do
  # opts
  # |> client()
  # |> post(@routes.estimate_charges, opts[:params])
  # |> gen_response(Responses.Login)
  # end

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

  defp gen_response({:ok, %{body: %{"message" => message} = body} = _env}, module)
       when message == "SUCCESS" do
    {:ok, %{body | "data" => validate_response(body["data"], module)}}
  end

  defp gen_response({:ok, %{body: body} = _env}, _module) do
    # IO.inspect(_env)
    {:error, body}
  end

  defp gen_response({:error, %{body: body}}, _module) when is_binary(body),
    do: {:error, %{"message" => body}}

  defp gen_response({:error, %{body: body}}, _module), do: {:error, body}

  defp validate_params(opts, module) do
    if opts[:params] do
      struct_str =
        opts[:params]
        |> Enum.map(fn {k, v} -> ~s[#{k}: #{inspect(v)}] end)
        |> Enum.join(", ")

      Code.eval_string(~s[%#{module}{#{struct_str}}])
    end

    opts
  end

  defp validate_response(response, module) do
    struct_str =
      response
      |> Enum.map(fn {k, v} -> ~s[#{k}: #{inspect(v)}] end)
      |> Enum.join(", ")

    dbg()

    ~s[%#{module}{#{struct_str}}]
    |> Code.eval_string()
    |> elem(0)
  end
end
