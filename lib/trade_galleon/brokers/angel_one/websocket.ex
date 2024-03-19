defmodule TradeGalleon.Brokers.AngelOne.WebSocket do
  @moduledoc """
  This module is responsible for handling the Quote WebSocket connection with AngelOne.
  doc: https://smartapi.angelbroking.com/docs/WebSocket2
  """
  use TradeGalleon.Adapter,
    required_config: [:api_key, :pub_sub_module, :supervisor]

  use WebSockex
  require Logger
  alias Phoenix.PubSub

  @url "wss://smartapisocket.angelone.in/smart-stream"
  @tick_interval :timer.seconds(15)
  @subscriber_tick_timeout :timer.minutes(5)

  @doc """
  Starts a new WebSocket connection with AngelOne.

  ## Examples

      iex> TradeGalleon.call(AngelOne.WebSocket, :new,
            params: %{
              client_code: client_code,
              token: token,
              feed_token: feed_token,
              pub_sub_topic: pub_sub_topic
            }
          )
  """
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
    case WebSockex.start_link(
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
         ) do
      {:ok, pid} ->
        Logger.info(
          "[TradeGalleon][AngelOne][WebSocket][#{name}][#{inspect(pid)}] Process started!!"
        )

        :timer.send_interval(@tick_interval, pid, :tick)
        {:ok, pid}

      e ->
        e
    end
  end

  def handle_info(
        :tick,
        %{supervisor: supervisor, subscriber_tick_timeout: subscriber_tick_timeout, name: name} =
          state
      ) do
    new_subscriber_tick_timeout = subscriber_tick_timeout - @tick_interval

    case new_subscriber_tick_timeout do
      timeout when timeout in 1000..(@tick_interval * 2) ->
        :timer.send_after(new_subscriber_tick_timeout, self(), :tick)

        Logger.info(
          "[WebSocket][AngelOne][#{name}][NOSUBS] Teminating process in #{new_subscriber_tick_timeout / 1000} seconds"
        )

        {:reply, {:text, "ping"}, %{state | subscriber_tick_timeout: new_subscriber_tick_timeout}}

      timeout when timeout in (@tick_interval * 2)..@subscriber_tick_timeout ->
        {:reply, {:text, "ping"}, %{state | subscriber_tick_timeout: new_subscriber_tick_timeout}}

      _ ->
        Logger.info("[WebSocket][AngelOne][#{name}][NOSUBS] Teminated process")
        :ok = DynamicSupervisor.terminate_child(supervisor, self())
    end
  end

  def handle_info(:subscriber_tick, state) do
    {:reply, {:text, "subscriber_tick_reset"},
     %{state | subscriber_tick_timeout: @subscriber_tick_timeout}}
  end

  def handle_cast({:send, frame}, %{name: name} = state) do
    :timer.send_after(0, name, :subscriber_tick)
    {:reply, frame, state}
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
    {:ok, state}
  end
end
