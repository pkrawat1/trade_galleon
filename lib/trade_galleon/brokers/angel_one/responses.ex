defmodule TradeGalleon.Brokers.AngelOne.Responses do
  defmodule Login do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "login response" do
      field(:jwtToken, :string)
      field(:refreshToken, :string)
      field(:feedToken, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule GenerateToken do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "generate token response" do
      field(:jwtToken, :string)
      field(:refreshToken, :string)
      field(:feedToken, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule Logout do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "logout response" do
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule Profile do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "profile response" do
      field(:clientcode, :string)
      field(:name, :string)
      field(:email, :string)
      field(:mobileno, :string)
      field(:pan, :string)
      field(:broker, :string)
      field(:exchanges, {:array, :string})
      field(:products, {:array, :string})
      field(:lastlogintime, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule Portfolio do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "porfolio response" do
      embeds_many :holdings, Holding do
        field(:tradingsymbol, :string)
        field(:exchange, :string)
        field(:isin, :string)
        field(:t1quantity, :integer)
        field(:realisedquantity, :integer)
        field(:quantity, :integer)
        field(:authorisedquantity, :integer)
        field(:product, :string)
        field(:collateralquantity, :integer)
        field(:collateraltype, :string)
        field(:averageprice, :float)
        field(:ltp, :float)
        field(:symboltoken, :string)
        field(:close, :float)
        field(:profitandloss, :float)
        field(:pnlpercentage, :float)
      end
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:holdings, with: &holding_changeset/2)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{holdings: data})

    def holding_changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.Holding.__schema__(:fields))
    end
  end

  defmodule Quote do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "quote response" do
      field(:fetched, {:array, :map})
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule CandleData do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "candle data response" do
      field(:data, {:array, {:array, :any}})
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{data: data})
  end

  defmodule Funds do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "funds response" do
      field(:availablecash, :string)
      field(:availableintradaypayin, :string)
      field(:availablelimitmargin, :string)
      field(:collateral, :string)
      field(:m2mrealized, :string)
      field(:m2munrealized, :string)
      field(:net, :string)
      field(:utiliseddebits, :string)
      field(:utilisedexposure, :string)
      field(:utilisedholdingsales, :string)
      field(:utilisedoptionpremium, :string)
      field(:utilisedpayout, :string)
      field(:utilisedspan, :string)
      field(:utilisedturnover, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule OrderStatus do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "order status schema" do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:ordertype, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:producttype, Ecto.Enum, values: [:INTRADAY, :DELIVERY])
      field(:duration, Ecto.Enum, values: [:DAY, :IOC])
      field(:price, :string)
      field(:triggerprice, :string)
      field(:quantity, :string)
      field(:disclosedquantity, :string)
      field(:squareoff, :string)
      field(:stoploss, :string)
      field(:trailingstoploss, :string)
      field(:tradingsymbol, :string)
      field(:transactiontype, Ecto.Enum, values: [:BUY, :SELL])
      field(:exchange, Ecto.Enum, values: [:NSE, :BSE, :NFO, :MCX, :BFO, :CDS])
      field(:symboltoken, :string)
      field(:instrumenttype, :string)
      field(:strikeprice, :string)
      field(:optiontype, :string)
      field(:expirydate, :string)
      field(:lotsize, :string)
      field(:cancelsize, :string)
      field(:averageprice, :string)
      field(:filledshares, :string)
      field(:unfilledshares, :string)
      field(:orderid, :string)
      field(:text, :string)
      field(:status, :string)
      field(:orderstatus, :string)
      field(:updatetime, :string)
      field(:exchtime, :string)
      field(:exchorderupdatetime, :string)
      field(:fillid, :string)
      field(:filltime, :string)
      field(:parentorderid, :string)
      field(:uniqueorderid, :string)
    end

    def changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.__schema__(:fields))
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule OrderBook do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "order book response" do
      embeds_many(:orders, TradeGalleon.Brokers.AngelOne.Responses.OrderStatus)
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:orders)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{orders: data})
  end

  defmodule TradeBook do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "trade book response" do
      embeds_many(:orders, TradeGalleon.Brokers.AngelOne.Responses.OrderStatus)
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:orders)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{trades: data})
  end

  defmodule SearchToken do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "search token response" do
      embeds_many :scrips, Scrip do
        field(:exchange, :string)
        field(:tradingsymbol, :string)
        field(:symboltoken, :string)
      end
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:scrips, with: &scrip_changeset/2)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{scrips: data})

    def scrip_changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.Scrip.__schema__(:fields))
    end
  end

  defmodule PlaceOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "place order response" do
      field(:script, :string)
      field(:orderid, :string)
      field(:uniqueorderid, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule ModifyOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "modify order response" do
      field(:orderid, :string)
      field(:uniqueorderid, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule CancelOrder do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "cancel order response" do
      field(:orderid, :string)
      field(:uniqueorderid, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule VerifyDis do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "verify dis response" do
      field(:ReqId, :string)
      field(:ReturnURL, :string)
      field(:DPId, :string)
      field(:BOID, :string)
      field(:TransDtls, :string)
      field(:version, :string)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule EstimateCharges do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "estimate charges response" do
      embeds_one :summary, Summary do
        field(:total_charges, :float)
        field(:trade_value, :float)

        embeds_many :breakup, Breakup do
          field(:name, :string)
          field(:amount, :float)
          field(:msg, :string)
          embeds_many(:breakup, Breakup)
        end
      end

      embeds_many :charges, Charge do
        field(:total_charges, :float)
        field(:trade_value, :float)
        embeds_many(:breakup, Breakup)
      end
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:summary, with: &summary_changeset/2)
      |> cast_embed(:charges, with: &charge_changeset/2)
      |> apply_action(:insert)
    end

    def summary_changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.Summary.__schema__(:fields))
    end

    def charge_changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.Charge.__schema__(:fields))
    end
  end
end
