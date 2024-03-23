defmodule TradeGalleon.Brokers.AngelOne.Responses do
  defmodule Login do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    embedded_schema do
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

    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :holdings, Holding do
        @derive Jason.Encoder
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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

    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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

    @derive Jason.Encoder
    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:ordertype, Ecto.Enum, values: [:MARKET, :LIMIT, :STOPLOSS_LIMIT, :STOPLOSS_MARKET])
      field(:producttype, Ecto.Enum, values: [:INTRADAY, :DELIVERY])
      field(:duration, Ecto.Enum, values: [:DAY, :IOC])
      field(:price, :float)
      field(:triggerprice, :float)
      field(:quantity, :integer)
      field(:disclosedquantity, :integer)
      field(:squareoff, :float)
      field(:stoploss, :float)
      field(:trailingstoploss, :float)
      field(:tradingsymbol, :string)
      field(:transactiontype, Ecto.Enum, values: [:BUY, :SELL])
      field(:exchange, Ecto.Enum, values: [:NSE, :BSE, :NFO, :MCX, :BFO, :CDS])
      field(:symboltoken, :string)
      field(:instrumenttype, :string)
      field(:strikeprice, :float)
      field(:optiontype, :string)
      field(:expirydate, :string)
      field(:lotsize, :string)
      field(:cancelsize, :string)
      field(:averageprice, :float)
      field(:filledshares, :integer)
      field(:unfilledshares, :integer)
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
      field(:ltp, :float)
      field(:ltp_percent, :float)
      field(:close, :float)
      field(:is_gain_today?, :boolean)
      field(:gain_or_loss, :float)
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :scrips, Scrip do
        @derive Jason.Encoder
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
    alias TradeGalleon.Brokers.AngelOne.Responses.EstimateCharges.Breakup
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :breakup, Breakup do
        @derive Jason.Encoder
        field(:name, :string)
        field(:amount, :float)
        field(:msg, :string)
        embeds_many(:breakup, Breakup)
      end

      embeds_one :summary, Summary do
        @derive Jason.Encoder
        field(:total_charges, :float)
        field(:trade_value, :float)

        embeds_many(:breakup, Breakup)
      end

      embeds_many :charges, Charge do
        @derive Jason.Encoder
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
      ch
      |> cast(attrs, __MODULE__.Summary.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end

    def charge_changeset(ch, attrs) do
      ch
      |> cast(attrs, __MODULE__.Charge.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end

    def breakup_changeset(ch, attrs) do
      ch
      |> cast(attrs, Breakup.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end
  end
end
