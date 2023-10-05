defmodule TradeGalleon.Adapter do
  @moduledoc """
    Broker API Configuration validator
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Tesla
      @required_config opts[:required_config] || []

      @doc """
      Catches broker api configuration errors.

      Raises a run-time `ArgumentError` if any of the `required_config` values
      is not available or missing from the Application config.
      """
      def validate_config(config) when is_list(config) do
        missing_keys =
          Enum.reduce(@required_config, [], fn key, missing_keys ->
            if config[key] in [nil, ""], do: [key | missing_keys], else: missing_keys
          end)

        raise_on_missing_config(missing_keys, config)
      end

      def validate_config(config) when is_map(config) do
        config
        |> Enum.into([])
        |> validate_config
      end

      def validate_config(nil) do
        raise ArgumentError, """
        expected broker config to be set

        ```
        # config/config.exs

        config :trade_galleon, TradeGalleon.Broker.BrokerXYZ,
          adapter: TradeGalleon.Broker.BrokerXYZ,
          secret_api_key: "some_api_key",
          secret_key: "some_secret_key"
        """
      end

      defp raise_on_missing_config([], _config), do: :ok

      defp raise_on_missing_config(key, config) do
        raise ArgumentError, """
        expected #{inspect(key)} to be set, got: #{inspect(config)}
        """
      end
    end
  end
end
