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
      field(:holdings, {:array, :map})
      field(:totalholding, :map)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
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

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
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
end
