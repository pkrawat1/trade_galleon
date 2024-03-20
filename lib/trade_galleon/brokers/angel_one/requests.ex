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
end
