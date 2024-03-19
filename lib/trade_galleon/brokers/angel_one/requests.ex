defmodule TradeGalleon.Brokers.AngelOne.Requests do
  defmodule Login do
    @enforce_keys [:clientcode, :password, :totp]
    defstruct @enforce_keys
  end

  defmodule GenerateToken do
    @enforce_keys [:refreshToken]
    defstruct @enforce_keys
  end

  defmodule Logout do
    @enforce_keys [:clientcode]
    defstruct @enforce_keys
  end

  defmodule Profile do
    defstruct [] 
  end

  defmodule Portfolio do
    defstruct [] 
  end

  defmodule Quote do
    defstruct [:mode, :exchangeTokens]
  end
end
