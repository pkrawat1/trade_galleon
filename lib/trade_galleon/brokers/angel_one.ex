defmodule TradeGalleon.Brokers.AngelOne do
  @moduledoc """
    AngelOne Smart api implementation
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
    portfolio: "rest/secure/angelbroking/portfolio/v1/getHolding"
  }

  @impl TradeGalleon.Broker
  def login(%{"clientcode" => _, "password" => _, "totp" => _} = params, opts) do
    opts
    |> client()
    |> post(@routes.login, params)
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def logout(%{token: token, client_code: client_code}) do
    client(token)
    |> post(@routes.logout, %{"clientcode" => client_code})
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def generate_token(%{token: token, refresh_token: refresh_token}) do
    client(token)
    |> post(@routes.generate_token, %{"refreshToken" => refresh_token})
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def profile(%{token: token}) do
    client(token)
    |> get(@routes.profile)
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def portfolio(%{token: token}) do
    client(token)
    |> get(@routes.portfolio)
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def client(opts \\ []) do
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
       max_retries: 10,
       max_delay: 4_000,
       should_retry: fn
         {:ok, %{status: status}} when status in [400, 403, 500] -> true
         {:ok, _} -> false
         {:error, _} -> true
       end}
    ]

    IO.inspect(middleware)

    Tesla.client(middleware)
  end

  defp gen_response({:ok, %{body: %{"message" => message} = body} = _env})
       when message == "SUCCESS" do
    IO.inspect(_env)
    {:ok, body}
  end

  defp gen_response({:ok, %{body: body} = _env}) do
    IO.inspect(_env)
    {:error, body}
  end

  defp gen_response({:error, %{body: body}}), do: {:error, body}
end
