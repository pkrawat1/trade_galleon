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
  @tick_interval 15000
  @subscriber_tick_timeout 120_000

  def new(opts) do
    extra_headers = [
      {"Authorization", "Bearer " <> get_in(opts, [:params, :token])},
      {"x-api-key", get_in(opts, [:config, :api_key])},
      {"x-client-code", get_in(opts, [:params, :client_code])},
      {"x-feed-token", get_in(opts, [:params, :feed_token])}
    ]

    name = :"#{get_in(opts, [:params, :client_code])}-quote-stream"

    DynamicSupervisor.start_child(
      get_in(opts, [:config, :supervisor]),
      {__MODULE__,
       %{
         pub_sub_module: get_in(opts, [:config, :pub_sub_module]),
         pub_sub_topic: get_in(opts, [:params, :pub_sub_topic]),
         extra_headers: extra_headers,
         supervisor: get_in(opts, [:config, :supervisor]),
         name: name
       }}
    )
  end

  def start_link(%{
        pub_sub_module: pub_sub_module,
        pub_sub_topic: pub_sub_topic,
        extra_headers: extra_headers,
        supervisor: supervisor,
        name: name
      }) do
    :timer.send_interval(@tick_interval, name, :tick)

    WebSockex.start_link(
      @url,
      __MODULE__,
      %{
        pub_sub_module: pub_sub_module,
        pub_sub_topic: pub_sub_topic,
        supervisor: supervisor,
        subscriber_tick_timeout: @subscriber_tick_timeout,
        name: name
      },
      extra_headers: extra_headers,
      name: name
    )
  end

  def handle_info(
        :tick,
        %{subscriber_tick_timeout: subscriber_tick_timeout} = state
      )
      when (subscriber_tick_timeout - @tick_interval) in 1000..@tick_interval do
    :timer.send(subscriber_tick_timeout - @tick_interval, self(), :tick)

    {:reply, {:text, "ping"},
     %{state | subscriber_tick_timeout: subscriber_tick_timeout - @tick_interval}}
  end

  def handle_info(
        :tick,
        %{supervisor: supervisor, name: name} = state
      ) do
    :ok = DynamicSupervisor.terminate_child(supervisor, self())
    Logger.info("[WebSocket][#{name}][NOSUBS] Teminated process")
    {:reply, {:text, "no_subscriber_tick"}, state}
  end

  def handle_info(:subscriber_tick, state) do
    Logger.info("[WebSocket][#{name}][SUB] Subcriber Tick")

    {:reply, {:text, "subscriber_tick"},
     %{state | subscriber_tick_timeout: @subscriber_tick_timeout}}
  end

  def handle_info(:data, state) do
    {:reply, state, state}
  end

  def handle_frame(
        {:binary,
         <<
           subscription_mode::little-integer-size(8),
           exchange_type::little-integer-size(8),
           token::binary-size(25),
           sequence_number::little-integer-size(64),
           exchange_timestamp::little-integer-size(64),
           last_traded_price::little-integer-size(64),
           last_traded_quantity::little-integer-size(64),
           avg_traded_price::little-integer-size(64),
           vol_traded::little-integer-size(64),
           total_buy_quantity::little-float-size(64),
           total_sell_quantity::little-float-size(64),
           open_price_day::little-integer-size(64),
           high_price_day::little-integer-size(64),
           low_price_day::little-integer-size(64),
           close_price::little-integer-size(64),
           _::little-integer-size(64),
           _::little-integer-size(64),
           _::little-integer-size(64),
           best_five::binary-size(200),
           _rest::binary
         >>},
        state
      ) do
    best_five =
      best_five
      |> :binary.bin_to_list()
      |> Enum.chunk_every(20)
      |> Enum.reverse()
      |> Enum.map(&:binary.list_to_bin(&1))
      |> Enum.reduce(%{buy: [], sell: []}, fn data, best_five ->
        <<flag::little-integer-size(16), quantity::little-integer-size(64),
          price::little-integer-size(64), _rest::binary>> = data

        new_data =
          %{quantity: quantity, price: price / 100}

        if flag == 1 do
          %{best_five | buy: [new_data | best_five.buy]}
        else
          %{best_five | sell: [new_data | best_five.sell]}
        end
      end)

    PubSub.broadcast(state.pub_sub_module, state.pub_sub_topic, %{
      topic: state.pub_sub_topic,
      payload: %{
        subscription_mode: subscription_mode,
        exchange_type: exchange_type,
        token: token |> to_charlist |> Enum.filter(&(&1 != 0)) |> to_string,
        sequence_number: sequence_number,
        exchange_timestamp: exchange_timestamp,
        last_traded_price: last_traded_price / 100,
        last_traded_quantity: last_traded_quantity,
        avg_traded_price: avg_traded_price / 100,
        vol_traded: vol_traded,
        total_buy_quantity: total_buy_quantity |> trunc,
        total_sell_quantity: total_sell_quantity |> trunc,
        open_price_day: open_price_day / 100,
        high_price_day: high_price_day / 100,
        low_price_day: low_price_day / 100,
        close_price: close_price / 100,
        best_five: best_five
      }
    })

    {:ok, state}
  end

  def handle_frame({_type, _msg}, state) do
    # Logger.info("Received Message - Topic: #{state.pub_sub_topic} -- Type: #{inspect(_type)} -- Message: #{inspect(_msg)}")
    {:ok, state}
  end
end
