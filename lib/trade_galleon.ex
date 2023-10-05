defmodule TradeGalleon do
  @moduledoc """
  Documentation for `TradeGalleon`.
  """

  def login(broker, params, opts \\ []) do
    config = get_and_validate_config(broker)
    broker.login(params, [{:config, config} | opts])
  end

  defp get_and_validate_config(broker) do
    config = Application.get_env(:trade_galleon, broker)
    broker.validate_config(config)
    global_config = Application.get_env(:trade_galleon, :global_config) || [mode: :test]
    Keyword.merge(global_config, config)
  end
end
