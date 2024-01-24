defmodule TradeGalleon.Brokers.AngelOne.WebSocket do
  @moduledoc """
    AngelOne smart stream socket
  """
  use TradeGalleon.Adapter,
    required_config: [:api_key, :pub_sub_module, :supervisor]

  use WebSockex
  require Logger
  alias Phoenix.PubSub

  @url "wss://smartapisocket.angelone.in/smart-stream"

  def new(opts) do
    extra_headers = [
      {"Authorization", "Bearer " <> get_in(opts, [:params, :token])},
      {"x-api-key", get_in(opts, [:config, :api_key])},
      {"x-client-code", get_in(opts, [:params, :client_code])},
      {"x-feed-token", get_in(opts, [:params, :feed_token])}
    ]

    name = :"#{get_in(opts, [:params, :client_code])}"

    DynamicSupervisor.start_child(
      get_in(opts, [:config, :supervisor]),
      {__MODULE__,
       %{
         pub_sub_module: get_in(opts, [:config, :pub_sub_module]),
         pub_sub_topic: get_in(opts, [:params, :pub_sub_topic]),
         extra_headers: extra_headers,
         name: name
       }}
    )
  end

  def start_link(%{
        pub_sub_module: pub_sub_module,
        pub_sub_topic: pub_sub_topic,
        extra_headers: extra_headers,
        name: name
      }) do
    :timer.send_interval(15000, name, :tick)

    WebSockex.start_link(
      @url,
      __MODULE__,
      %{
        pub_sub_module: pub_sub_module,
        pub_sub_topic: pub_sub_topic
      },
      extra_headers: extra_headers,
      name: name
    )
  end

  def handle_info(
        :tick,
        state
      ) do
    {:reply, {:text, "ping"}, state}
  end

  def handle_info(:data, state) do
    {:reply, state, state}
  end

  def handle_frame(
        {:binary,
         <<subscription_mode::little-integer-size(8), exchange_type::little-integer-size(8),
           token::binary-size(25), _sequence_number::little-integer-size(64),
           _exchange_timestamp::little-integer-size(64),
           last_traded_price::little-integer-size(64),
           last_traded_quantity::little-integer-size(64),
           avg_traded_price::little-integer-size(64), vol_traded::little-integer-size(64),
           total_buy_quantity::float-size(64), total_sell_quantity::float-size(64),
           open_price_day::little-integer-size(64), high_price_day::little-integer-size(64),
           low_price_day::little-integer-size(64), close_price::little-integer-size(64),
           _rest::binary>>},
        state
      ) do
    PubSub.broadcast(state.pub_sub_module, state.pub_sub_topic, %{
      topic: state.pub_sub_topic,
      payload: %{
        token: token |> to_charlist |> Enum.filter(&(&1 != 0)) |> to_string,
        subscription_mode: subscription_mode,
        exchange_type: exchange_type,
        last_traded_price: last_traded_price,
        last_traded_quantity: last_traded_quantity,
        avg_traded_price: avg_traded_price,
        vol_traded: vol_traded,
        total_buy_quantity: total_buy_quantity,
        total_sell_quantity: total_sell_quantity,
        open_price_day: open_price_day,
        high_price_day: high_price_day,
        low_price_day: low_price_day,
        close_price: close_price
      }
    })

    {:ok, state}
  end

  def handle_frame({_type, _msg}, state) do
    # Logger.info("Received Message - Topic: #{state.pub_sub_topic} -- Type: #{inspect(_type)} -- Message: #{inspect(_msg)}")
    {:ok, state}
  end
end
