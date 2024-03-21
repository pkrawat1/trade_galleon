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

  defmodule OrderBook do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "order book response" do
      field(:orders, {:array, :map})
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{orders: data})
  end

  defmodule TradeBook do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "trade book response" do
      field(:orders, {:array, :map})
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
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
end
