defmodule TradeGalleon.Brokers.AngelOne.Requests do
  defmodule Login do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(clientcode password totp)a
    @optional ~w()a

    @primary_key false
    schema "login params" do
      field(:clientcode, :string)
      field(:password, :string)
      field(:totp, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule GenerateToken do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(refreshToken)a
    @optional ~w()a

    @primary_key false
    schema "generate token params" do
      field(:refreshToken, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule Logout do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(clientcode)a
    @optional ~w()a

    @primary_key false
    schema "logout params" do
      field(:clientcode, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule Profile do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    schema "profile params" do
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule Portfolio do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    schema "portfolio params" do
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule Quote do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(mode exchangeTokens)a
    @optional ~w()a

    @primary_key false
    schema "quote params" do
      field(:mode, :string)
      field(:exchangeTokens, :map)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule CandleData do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(exchange symboltoken interval fromdate todate)a
    @optional ~w()a

    @primary_key false
    schema "candle data params" do
      field(:exchange, :string)
      field(:symboltoken, :string)
      field(:interval, :string)
      field(:fromdate, :string)
      field(:todate, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule Funds do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    schema "funds params" do
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule OrderBook do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    schema "order book params" do
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule TradeBook do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w()a
    @optional ~w()a

    @primary_key false
    schema "trade book params" do
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule SearchToken do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(exchange searchscrip)a
    @optional ~w()a

    @primary_key false
    schema "search token params" do
      field(:exchange, :string)
      field(:searchscrip, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end

  defmodule PlaceOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(variety tradingsymbol symboltoken exchange transactiontype ordertype quantity producttype price duration)a
    @optional ~w(triggerprice squareoff stoploss trailingStopLoss disclosedquantity ordertag)a

    @primary_key false
    schema "place order params" do
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

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
      |> validate_market_order()
      |> validate_stoploss_order()
      |> validate_robo_order()
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

  defmodule VerifyDis do
    use Ecto.Schema
    import Ecto.Changeset

    @required ~w(isin)a
    @optional ~w()a

    @primary_key false
    schema "verify dis params" do
      field(:isin, :string)
      field(:quantity, :string)
    end

    def changeset(ch, params) do
      cast(ch, params, @required ++ @optional)
      |> validate_required(@required)
    end
  end
end
