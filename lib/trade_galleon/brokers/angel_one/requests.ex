defmodule TradeGalleon.Brokers.AngelOne.Requests do
  defmodule Login do
    use Ecto.Schema
    import Ecto.Changeset

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(struct, opts) do
        Jason.Encode.map(
          %{
            clientcode: struct.client_code,
            password: struct.password,
            totp: struct.totp
          },
          opts
        )
      end
    end

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

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(struct, opts) do
        Jason.Encode.map(
          %{
            refreshToken: struct.refresh_token
          },
          opts
        )
      end
    end

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

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(struct, opts) do
        Jason.Encode.map(
          %{
            clientcode: struct.client_code
          },
          opts
        )
      end
    end

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

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(struct, opts) do
        Jason.Encode.map(
          struct
          |> Map.to_list()
          |> Enum.map(fn {k, v} -> {Macro.camelize(":#{k}"), v} end)
          |> Enum.into(%{}),
          opts
        )
        |> dbg()
      end
    end

    @required ~w(mode exchange_tokens)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:mode, :string)
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
    import Ecto.Changeset

    @required ~w(exchange symboltoken interval fromdate todate)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:exchange, :string)
      field(:symboltoken, :string)
      field(:interval, :string)
      field(:fromdate, :string)
      field(:todate, :string)
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
    import Ecto.Changeset

    @required ~w(exchange searchscrip)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:exchange, :string)
      field(:searchscrip, :string)
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
    import Ecto.Changeset

    @required ~w(variety tradingsymbol symboltoken exchange transactiontype ordertype quantity producttype price duration)a
    @optional ~w(triggerprice squareoff stoploss trailingStopLoss disclosedquantity ordertag)a

    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:tradingsymbol, :string)
      field(:symboltoken, :string)
      field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
      field(:transactiontype, Ecto.Enum, values: [:BUY, :SELL])
      field(:ordertype, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:quantity, :string)
      field(:producttype, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:price, :string)
      field(:triggerprice, :string)
      field(:squareoff, :string)
      field(:stoploss, :string)
      field(:trailingStopLoss, :string)
      field(:disclosedquantity, :string)
      field(:duration, Ecto.Enum, values: [:DAY, :IOC])
      field(:ordertag, :string)
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
      if get_field(ch, :ordertype) == :MARKET do
        put_change(ch, :price, 0)
      else
        ch
      end
    end

    defp validate_stoploss_order(ch) do
      if get_field(ch, :ordertype) == :STOPLOSS_LIMIT ||
           get_field(ch, :ordertype) == :STOPLOSS_MARKET do
        validate_required(ch, [:triggerprice])
      else
        ch
      end
    end

    defp validate_robo_order(ch) do
      if get_field(ch, :variety) == :ROBO do
        validate_required(ch, [:squareoff, :stoploss, :trailingStopLoss])
      else
        ch
      end
    end
  end

  defmodule ModifyOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(orderid exchange)a
    @optional ~w(variety tradingsymbol symboltoken transactiontype ordertype quantity producttype price triggerprice disclosedquantity)a

    @primary_key false
    embedded_schema do
      field(:orderid, :string)
      field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:tradingsymbol, :string)
      field(:symboltoken, :string)
      field(:transactiontype, Ecto.Enum, values: [:BUY, :SELL])
      field(:ordertype, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:quantity, :string)
      field(:producttype, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:price, :string)
      field(:triggerprice, :string)
      field(:disclosedquantity, :string)
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
      if get_field(ch, :ordertype) == :MARKET do
        put_change(ch, :price, 0)
      else
        ch
      end
    end

    defp validate_stoploss_order(ch) do
      if get_field(ch, :ordertype) == :STOPLOSS_LIMIT ||
           get_field(ch, :ordertype) == :STOPLOSS_MARKET do
        validate_required(ch, [:triggerprice])
      else
        ch
      end
    end

    defp validate_robo_order(ch) do
      if get_field(ch, :variety) == :ROBO do
        validate_required(ch, [:squareoff, :stoploss, :trailingStopLoss])
      else
        ch
      end
    end
  end

  defmodule CancelOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(orderid variety)a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:orderid, :string)
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

  defmodule EstimateCharges do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    embedded_schema do
      embeds_many :orders, Order do
        field(:token, :string)
        field(:exchange, Ecto.Enum, values: [:BSE, :NSE, :NFO, :MCX, :BFO, :CDS])
        field(:transaction_type, Ecto.Enum, values: [:BUY, :SELL])
        field(:quantity, :integer)

        field(:product_type, Ecto.Enum,
          values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO]
        )

        field(:price, :decimal)
      end
    end

    def to_schema(params) do
      %__MODULE__{}
      |> cast(params, @required ++ @optional)
      |> validate_required(@required)
      |> cast_embed(:orders, with: &order_changeset/2)
      |> apply_action(:insert)
    end

    def order_changeset(ch, params) do
      cast(ch, params, __MODULE__.Order.__schema__(:fields))
    end
  end
end
