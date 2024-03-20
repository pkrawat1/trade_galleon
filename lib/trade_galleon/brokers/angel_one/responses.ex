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
      |> cast(data, ~w(jwtToken refreshToken feedToken)a)
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
      |> cast(data, ~w(jwtToken refreshToken feedToken)a)
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
      |> cast(data, [])
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
      |> cast(data, [])
      |> apply_action(:insert)
    end
  end

  defmodule Portfolio do
    defstruct [:holdings]
  end

  defmodule Quote do
    defstruct []
  end

  defmodule CandleData do
    defstruct []
  end

  defmodule Funds do
    defstruct [
      :availablecash,
      :availableintradaypayin,
      :availablelimitmargin,
      :collateral,
      :m2mrealized,
      :m2munrealized,
      :net,
      :utiliseddebits,
      :utilisedexposure,
      :utilisedholdingsales,
      :utilisedoptionpremium,
      :utilisedpayout,
      :utilisedspan,
      :utilisedturnover
    ]
  end
end
