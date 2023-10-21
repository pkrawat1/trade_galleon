defmodule TradeGalleonTest do
  use ExUnit.Case
  doctest TradeGalleon
  import TradeGalleon

  @test_config [
    some_auth_info: :broker_secret_key,
    other_secret: :sun_rises_in_the_east
  ]
  @bad_config [some_auth_info: :broker_secret_key]

  defmodule FakeBroker do
    use TradeGalleon.Adapter, required_config: [:some_auth_info, :other_secret]

    def login(_) do
      :auth_tokens
    end
  end

  setup do
    Application.put_env(:trade_galleon, TradeGalleonTest.FakeBroker, @test_config)
    :ok
  end

  test "login" do
    assert call(FakeBroker, :login, %{}) == :auth_tokens
  end

  test "validate_config when some required config is missing" do
    Application.put_env(:trade_galleon, FakeBroker, @bad_config)

    assert_raise(
      ArgumentError,
      "expected [:other_secret] to be set, got: [some_auth_info: :broker_secret_key]\n",
      fn -> call(FakeBroker, :login) end
    )
  end
end
