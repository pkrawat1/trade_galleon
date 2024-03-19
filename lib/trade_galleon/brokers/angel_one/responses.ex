defmodule TradeGalleon.Brokers.AngelOne.Responses do
  defmodule Login do
    defstruct [:jwtToken, :refreshToken, :feedToken]
  end

  defmodule GenerateToken do
    defstruct [:jwtToken, :refreshToken, :feedToken]
  end

  defmodule Logout do
    defstruct []
  end

  defmodule Profile do
    defstruct [:clientcode, :name, :email, :mobile, :pan]
  end

  defmodule Portfolio do
    defstruct [:holdings]
  end

  defmodule Quote do
    defstruct []
  end
end
