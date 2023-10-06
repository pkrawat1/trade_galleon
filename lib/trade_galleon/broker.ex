defmodule TradeGalleon.Broker do
  @callback client(opts :: Keyword.t()) :: Tesla.Client.t()
end
