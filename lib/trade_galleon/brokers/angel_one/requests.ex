defmodule TradeGalleon.Brokers.AngelOne.Requests do
  defmodule Login do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(client_code password totp)a
    @optional ~w()a

    embedded_schema do
      field(:client_code, :string)
      field(:password, :string)
      field(:totp, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule GenerateToken do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w(refresh_token)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:refresh_token, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule Logout do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :remove_underscore

    @required ~w(client_code)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:client_code, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule Profile do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule Portfolio do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule Quote do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :camel_case

    @required ~w(mode exchange_tokens)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:mode, Ecto.Enum, values: [:FULL, :LTP, :OHLC])
      field(:exchange_tokens, :map)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule CandleData do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(exchange symbol_token interval from_date to_date)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:exchange, :string)
      field(:symbol_token, :string)
      field(:interval, :string)
      field(:from_date, :string)
      field(:to_date, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule Funds do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule OrderBook do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule TradeBook do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :underscore

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule SearchToken do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(exchange search_scrip)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:exchange, :string)
      field(:search_scrip, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule PlaceOrder do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(variety trading_symbol symbol_token exchange transaction_type order_type quantity product_type price duration)a
    @optional ~w(trigger_price square_off stoploss trailing_stoploss disclosed_quantity order_tag)a

    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:trading_symbol, :string)
      field(:symbol_token, :string)
      field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
      field(:transaction_type, Ecto.Enum, values: [:BUY, :SELL])
      field(:order_type, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:quantity, :string)
      field(:product_type, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:price, :string)
      field(:trigger_price, :string)
      field(:square_off, :string)
      field(:stoploss, :string)
      field(:trailing_stoploss, :string)
      field(:disclosed_quantity, :string)
      field(:duration, Ecto.Enum, values: [:DAY, :IOC])
      field(:order_tag, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> validate_market_order()
      |> validate_stoploss_order()
      |> validate_robo_order()
      |> apply_action(:insert)
    end

    defp validate_market_order(ch) do
      if get_field(ch, :order_type) == :MARKET do
        put_change(ch, :price, 0)
      else
        ch
      end
    end

    defp validate_stoploss_order(ch) do
      if get_field(ch, :order_type) == :STOPLOSS_LIMIT ||
           get_field(ch, :order_type) == :STOPLOSS_MARKET do
        validate_required(ch, [:trigger_price])
      else
        ch
      end
    end

    defp validate_robo_order(ch) do
      if get_field(ch, :variety) == :ROBO do
        validate_required(ch, [:square_off, :stoploss, :trailing_stoploss])
      else
        ch
      end
    end
  end

  defmodule ModifyOrder do
    use Ecto.Schema
    import Ecto.Changeset
    use Encoder, encode: :remove_underscore

    @required ~w(order_id exchange)a
    @optional ~w(variety trading_symbol symbol_token transaction_type order_type quantity product_type price trigger_price disclosed_quantity)a

    @primary_key false
    embedded_schema do
      field(:order_id, :string)
      field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:trading_symbol, :string)
      field(:symbol_token, :string)
      field(:transaction_type, Ecto.Enum, values: [:BUY, :SELL])
      field(:order_type, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:quantity, :string)
      field(:product_type, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:price, :string)
      field(:trigger_price, :string)
      field(:disclosed_quantity, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> validate_market_order()
      |> validate_stoploss_order()
      |> validate_robo_order()
      |> apply_action(:insert)
    end

    defp validate_market_order(ch) do
      if get_field(ch, :order_type) == :MARKET do
        put_change(ch, :price, 0)
      else
        ch
      end
    end

    defp validate_stoploss_order(ch) do
      if get_field(ch, :order_type) == :STOPLOSS_LIMIT ||
           get_field(ch, :order_type) == :STOPLOSS_MARKET do
        validate_required(ch, [:trigger_price])
      else
        ch
      end
    end

    defp validate_robo_order(ch) do
      if get_field(ch, :variety) == :ROBO do
        validate_required(ch, [:square_off, :stoploss, :trailing_stoploss])
      else
        ch
      end
    end
  end

  defmodule CancelOrder do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(order_id variety)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:order_id, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule OrderStatus do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(unique_order_id)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:unique_order_id, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule VerifyDis do
    use Ecto.Schema
    use Encoder, encode: :remove_underscore
    import Ecto.Changeset

    @required ~w(isin quantity)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:isin, :string)
      field(:quantity, :string)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> apply_action(:insert)
    end
  end

  defmodule EstimateCharges.Order do
    use Ecto.Schema
    use Encoder, encode: :underscore
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:token, :string)
      field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
      field(:transaction_type, Ecto.Enum, values: [:BUY, :SELL])
      field(:quantity, :integer)
      field(:product_type, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:price, :decimal)
    end

    def changeset(ch, params) do
      ch
      |> cast(params, __MODULE__.__schema__(:fields))
      |> validate_required(__MODULE__.__schema__(:fields))
    end
  end

  defmodule EstimateCharges do
    use Ecto.Schema
    use Encoder, encode: :underscore
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      embeds_many(:orders, __MODULE__.Order)
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> cast_embed(:orders)
      |> apply_action(:insert)
    end
  end
end
