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
  def login(%{"clientcode" => _, "password" => _, "totp" => _} = params) do
    client()
    |> post(@routes.login, params)
    |> gen_response()
  end

  def logout(%{token: token, client_code: client_code}) do
    client(token)
    |> post(@routes.logout, %{"clientcode" => client_code})
    |> gen_response()
  end

  def generate_token(%{token: token, refresh_token: refresh_token}) do
    client(token)
    |> post(@routes.generate_token, %{"refreshToken" => refresh_token})
    |> gen_response()
  end

  def profile(%{token: token}) do
    client(token)
    |> get(@routes.profile)
    |> gen_response()
  end

  def portfolio(%{token: token}) do
    client(token)
    |> get(@routes.portfolio)
    |> gen_response()
  end

  @impl TradeGalleon.Broker
  def client(opts \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"X-UserType", "USER"},
      {"X-SourceID", "WEB"},
      {"X-ClientLocalIP", ops[:local_ip]},
      {"X-ClientPublicIP", opts[:public_ip]},
      {"X-MACAddress", opts[:mac_address]},
      {"X-PrivateKey", opts[:api_key]}
    ]

    headers =
      if opts[:token] do
        [{"authorization", "Bearer " <> token} | headers]
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

    Tesla.client(middleware)
  end

  defp gen_response({:ok, %{body: %{"message" => message} = body} = _env})
       when message == "SUCCESS" do
    {:ok, body}
  end

  defp gen_response({:ok, %{body: body} = _env}) do
    {:error, body}
  end

  defp gen_response({:error, %{body: body}}), do: {:error, body}
end
