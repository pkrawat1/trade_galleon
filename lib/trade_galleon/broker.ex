defmodule TradeGalleon.Broker do
  @callback client(opts :: Keyword.t()) :: Tesla.Client.t()
  @callback login(params :: term) :: term
  @callback logout(params :: term) :: term
  @callback generate_token(params :: term) :: term
  @callback profile(params :: term) :: term
  @callback portfolio(params :: term) :: term
end
