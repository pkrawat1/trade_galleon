defmodule TradeGalleon.Brokers.AngelOne.Responses do
  defmodule Login do
    defstruct [:jwtToken, :refreshToken, :feedToken]
  end

  defmodule GenerateToken do
    defstruct [:jwtToken, :refreshToken, :feedToken]
  end
end
