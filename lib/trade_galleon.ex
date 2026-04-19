defmodule TradeGalleon do
  @moduledoc """
  Documentation for `TradeGalleon`.
  """

  def call(broker, action, opts \\ []) do
    config = get_and_validate_config(broker)
    apply(broker, action, [[{:config, config} | opts]])
  end

  @doc """
  Call a broker action with a per-call config override merged on top of the
  base Application config. Use this when credentials differ per client.
  """
  def call(broker, action, config_override, opts)
      when is_list(config_override) and is_list(opts) do
    base_config = Application.get_env(:trade_galleon, broker) || []
    merged_config = Keyword.merge(base_config, config_override)
    broker.validate_config(merged_config)
    global_config = Application.get_env(:trade_galleon, :global_config) || [mode: :test]
    config = Keyword.merge(global_config, merged_config)
    apply(broker, action, [[{:config, config} | opts]])
  end

  defp get_and_validate_config(broker) do
    config = Application.get_env(:trade_galleon, broker)
    broker.validate_config(config)
    global_config = Application.get_env(:trade_galleon, :global_config) || [mode: :test]
    Keyword.merge(global_config, config)
  end
end
