defmodule TradeGalleon do
  @moduledoc """
  Documentation for `TradeGalleon`.
  """

  def call(broker, action, opts \\ []) do
    config = get_and_validate_config(broker)
    apply(broker, action, [[{:config, config} | opts]])
  end

  defp get_and_validate_config(broker) do
    config = Application.get_env(:trade_galleon, broker)
    broker.validate_config(config)
    global_config = Application.get_env(:trade_galleon, :global_config) || [mode: :test]
    Keyword.merge(global_config, config)
  end
end
