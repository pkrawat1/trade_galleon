defmodule TradeGalleon.Brokers.AngelOne.Requests do
  defmodule Login do
    @enforce_keys [:clientcode, :password, :totp]
    defstruct @enforce_keys
  end

  defmodule GenerateToken do
    @enforce_keys [:refresh_token]
    defstruct @enforce_keys
  end
end
