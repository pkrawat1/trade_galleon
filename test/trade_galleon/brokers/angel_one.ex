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

  setup do
    Application.put_env(:trade_galleon, Broker, @config)

    Tesla.Mock.mock(fn
      %{method: :get} ->
        %Tesla.Env{status: 200, body: "hello"}
    end)

    :ok
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
               TradeGalleon.call(Broker, :login,
                 params: %{"clientcode" => "", "password" => "", "totp" => ""}
               )

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
  end

  test "logout"
  test "generate_token"
  test "profile"
  test "portfolio"
end