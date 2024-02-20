defmodule TradeGalleon.Brokers.AngelOne.WebSocketOrderStatus do
  @moduledoc """
    AngelOne Websocket Order Status
  """
  use TradeGalleon.Adapter,
    required_config: [:pub_sub_module, :supervisor]

  use WebSockex
  require Logger
  alias Phoenix.PubSub

  @url "wss://tns.angelone.in/smart-order-update"

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
    :timer.send_interval(9000, name, :tick)

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
