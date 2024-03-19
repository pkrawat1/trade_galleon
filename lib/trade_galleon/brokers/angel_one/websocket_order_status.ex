defmodule TradeGalleon.Brokers.AngelOne.WebSocketOrderStatus do
  @moduledoc """
  This module is responsible for handling the WebSocket connection for order status updates from AngelOne.
  doc: https://smartapi.angelbroking.com/docs/WebSocketOrderStatus
  """
  use TradeGalleon.Adapter,
    required_config: [:pub_sub_module, :supervisor]

  use WebSockex
  require Logger
  alias Phoenix.PubSub

  @url "wss://tns.angelone.in/smart-order-update"
  @tick_interval :timer.seconds(9)
  @subscriber_tick_timeout :timer.minutes(5)

  @doc """
  Starts a new WebSocket connection for order status updates from AngelOne.

  ## Examples

      iex> TradeGalleon.call(AngelOne.WebSocketOrderStatus, :new,
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
      {"Authorization", "Bearer " <> get_in(opts, [:params, :token])}
    ]

    name = :"#{get_in(opts, [:params, :client_code])}-order-stream"

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

  def handle_cast(:subscriber_tick, %{name: name} = state) do
    :timer.send_after(0, name, :subscriber_tick)
    {:reply, {:text, "subscriber_tick"}, state}
  end

  def handle_frame({_, msg}, state) do
    case Jason.decode(msg) do
      {:ok, json_data} ->
        PubSub.broadcast(state.pub_sub_module, state.pub_sub_topic, %{
          topic: state.pub_sub_topic,
          payload: json_data
        })

      _ ->
        nil
    end

    {:ok, state}
  end
end
