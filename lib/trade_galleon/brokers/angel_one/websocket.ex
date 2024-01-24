defmodule TradeGalleon.Brokers.AngelOne.WebSocket do
  @moduledoc """
    AngelOne smart stream socket
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use WebSockex
      require Logger
      alias Phoenix.PubSub

      @pub_sub_module opts[:pub_sub_module]

      @url "wss://smartapisocket.angelone.in/smart-stream"

      def start(%{client_code: client_code, token: token, feed_token: feed_token}) do
        extra_headers = [
          {"Authorization", "Bearer " <> token},
          {"x-api-key",
           Application.get_env(:trade_galleon, TradeGalleon.Brokers.AngelOne)[:api_key]},
          {"x-client-code", client_code},
          {"x-feed-token", feed_token}
        ]

        name = :"#{client_code}"

        case WebSockex.start(
               @url,
               __MODULE__,
               %{pub_sub_topic: "quote-stream-" <> client_code, client_code: client_code},
               extra_headers: extra_headers,
               name: name
             ) do
          {:ok, _} ->
            :timer.send_interval(15000, name, :tick)
            {:ok, name}

          e ->
            e
        end
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
        PubSub.broadcast(@pub_sub_module, state.pub_sub_topic, %{
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
  end
end
