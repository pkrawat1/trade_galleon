defmodule TradeGalleon.Brokers.AngelOne.Responses do
  @moduledoc """
  This module contains all the response schemas for AngelOne broker.
  """

  defmodule Login do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:jwt_token, :string)
      field(:refresh_token, :string)
      field(:feed_token, :string)
    end

    def to_schema(data) do
      data = Encoder.underscore_keys(data)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule GenerateToken do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:jwt_token, :string)
      field(:refresh_token, :string)
      field(:feed_token, :string)
    end

    def to_schema(data) do
      data = Encoder.underscore_keys(data)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule Logout do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
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

    @derive Jason.Encoder

    @primary_key false

    embedded_schema do
      field(:client_code, :string)
      field(:name, :string)
      field(:email, :string)
      field(:mobileno, :string)
      field(:pan, :string)
      field(:broker, :string)
      field(:exchanges, {:array, :string})
      field(:products, {:array, :string})
      field(:last_login_time, :string)
    end

    def to_schema(data) do
      data =
        Encoder.underscore_keys(data, fn
          :clientcode -> :client_code
          :mobileno -> :mobile_no
          :lastlogintime -> :last_login_time
          x -> x
        end)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule Portfolio do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :holdings, Holding do
        @derive Jason.Encoder
        field(:trading_symbol, :string)
        field(:exchange, :string)
        field(:isin, :string)
        field(:t1_quantity, :integer)
        field(:realised_quantity, :integer)
        field(:quantity, :integer)
        field(:authorised_quantity, :integer)
        field(:product, :string)
        field(:collateral_quantity, :integer)
        field(:collateral_type, :string)
        field(:average_price, :float)
        field(:ltp, :float)
        field(:symbol_token, :string)
        field(:close, :float)
        field(:profit_and_loss, :float)
        field(:pnl_percentage, :float)
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
      attrs =
        Encoder.underscore_keys(attrs, fn
          :tradingsymbol -> :trading_symbol
          :t1quantity -> :t1_quantity
          :realisedquantity -> :realised_quantity
          :authorisedquantity -> :authorised_quantity
          :collateralquantity -> :collateral_quantity
          :collateraltype -> :collateral_type
          :averageprice -> :average_price
          :symboltoken -> :symbol_token
          :profitandloss -> :profit_and_loss
          :pnlpercentage -> :pnl_percentage
          x -> x
        end)

      cast(ch, attrs, __MODULE__.Holding.__schema__(:fields))
    end
  end

  defmodule Quote.Data do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:exchange, :string)
      field(:trading_symbol, :string)
      field(:symbol_token, :string)
      field(:ltp, :float)
      field(:open, :float)
      field(:high, :float)
      field(:low, :float)
      field(:close, :float)
      field(:last_trade_qty, :integer)
      field(:exch_feed_time, :string)
      field(:exch_trade_time, :string)
      field(:net_change, :float)
      field(:percent_change, :float)
      field(:avg_price, :float)
      field(:trade_volume, :integer)
      field(:opn_interest, :integer)
      field(:lower_circuit, :float)
      field(:upper_circuit, :float)
      field(:tot_buy_quan, :integer)
      field(:tot_sell_quan, :integer)
      field(:"52_week_low", :float)
      field(:"52_week_high", :float)

      embeds_one :depth, Depth do
        @derive Jason.Encoder
        embeds_many :buy, Order do
          @derive Jason.Encoder
          field(:price, :float)
          field(:quantity, :integer)
          field(:orders, :integer)
        end

        embeds_many(:sell, __MODULE__.Order)
      end

      field(:message, :string)
      field(:error_code, :string)
    end

    def changeset(ch, attrs) do
      attrs =
        Encoder.underscore_keys(attrs, fn
          :tradingsymbol -> :trading_symbol
          :symboltoken -> :symbol_token
          :lasttradeqty -> :last_trade_qty
          :exchfeedtime -> :exch_feed_time
          :exchtradetime -> :exch_trade_time
          :netchange -> :net_change
          :percentchange -> :percent_change
          :avgprice -> :avg_price
          :tradevolume -> :trade_volume
          :opninterest -> :opn_interest
          :lowercircuit -> :lower_circuit
          :uppercircuit -> :upper_circuit
          :totbuyquan -> :tot_buy_quan
          :totsellquan -> :tot_sell_quan
          :"52weeklow" -> :"52_week_low"
          :"52weekhigh" -> :"52_week_high"
          x -> x
        end)

      ch
      |> cast(attrs, __MODULE__.__schema__(:fields) -- [:depth])
      |> cast_embed(:depth, with: &depth_changeset/2)
    end

    def depth_changeset(ch, attrs) do
      ch
      |> cast(attrs, __MODULE__.Depth.__schema__(:fields) -- [:buy, :sell])
      |> cast_embed(:buy, with: &order_changeset/2)
      |> cast_embed(:sell, with: &order_changeset/2)
    end

    def order_changeset(ch, attrs) do
      cast(ch, attrs, __MODULE__.Depth.Order.__schema__(:fields))
    end
  end

  defmodule Quote do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many(:fetched, __MODULE__.Data)
      embeds_many(:unfetched, __MODULE__.Data)
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields) -- [:fetched, :unfetched])
      |> cast_embed(:fetched)
      |> cast_embed(:unfetched)
      |> apply_action(:insert)
    end
  end

  defmodule CandleData do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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

    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
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
      data =
        Encoder.underscore_keys(data, fn
          :availablecash -> :available_cash
          :availableintradaypayin -> :available_intraday_payin
          :availablelimitmargin -> :available_limit_margin
          :m2mrealized -> :m2m_realized
          :m2munrealized -> :m2m_unrealized
          :utiliseddebits -> :utilised_debits
          :utilisedexposure -> :utilised_exposure
          :utilisedholdingsales -> :utilised_holding_sales
          :utilisedoptionpremium -> :utilised_option_premium
          :utilisedpayout -> :utilised_payout
          :utilisedspan -> :utilised_span
          :utilisedturnover -> :utilised_turnover
          x -> x
        end)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule OrderStatus do
    use Ecto.Schema
    import Ecto.Changeset

    @derive Jason.Encoder
    @primary_key false
    embedded_schema do
      field(:variety, Ecto.Enum, values: [:NORMAL, :STOPLOSS, :AMO, :ROBO])
      field(:order_type, Ecto.Enum, values: [:MARKET, :LIMIT, :SL, :SLM])
      field(:product_type, Ecto.Enum, values: [:DELIVERY, :CARRYFORWARD, :MARGIN, :INTRADAY, :BO])
      field(:duration, Ecto.Enum, values: [:DAY, :IOC])
      field(:price, :float)
      field(:trigger_price, :float)
      field(:quantity, :integer)
      field(:disclosed_quantity, :integer)
      field(:squareoff, :float)
      field(:stoploss, :float)
      field(:trailing_stoploss, :float)
      field(:trading_symbol, :string)
      field(:transaction_type, Ecto.Enum, values: [:BUY, :SELL])
      field(:exchange, Ecto.Enum, values: [:NSE, :BSE, :NFO, :MCX, :BFO, :CDS])
      field(:symbol_token, :string)
      field(:instrument_type, :string)
      field(:strike_price, :float)
      field(:option_type, :string)
      field(:expiry_date, :string)
      field(:lot_size, :string)
      field(:cancel_size, :string)
      field(:average_price, :float)
      field(:filled_shares, :integer)
      field(:unfilled_shares, :integer)
      field(:order_id, :string)
      field(:text, :string)
      field(:status, :string)
      field(:order_status, :string)
      field(:update_time, :string)
      field(:exchange_time, :string)
      field(:exchange_order_update_time, :string)
      field(:fill_id, :string)
      field(:fill_time, :string)
      field(:parent_order_id, :string)
      field(:unique_order_id, :string)
      field(:ltp, :float)
      field(:ltp_percent, :float)
      field(:close, :float)
      field(:is_gain_today?, :boolean)
      field(:gains_or_loss, :float)
    end

    defp field_mapper do
      fn
        :ordertype -> :order_type
        :producttype -> :product_type
        :triggerprice -> :trigger_price
        :disclosedquantity -> :disclosed_quantity
        :tradingsymbol -> :trading_symbol
        :symboltoken -> :symbol_token
        :transactiontype -> :transaction_type
        :instrumenttype -> :instrument_type
        :strikeprice -> :strike_price
        :optiontype -> :option_type
        :expirydate -> :expiry_date
        :lotsize -> :lot_size
        :cancelsize -> :cancel_size
        :averageprice -> :average_price
        :filledshares -> :filled_shares
        :unfilledshares -> :unfilled_shares
        :orderid -> :order_id
        :orderstatus -> :order_status
        :updatetime -> :update_time
        :exchtime -> :exchange_time
        :exchorderupdatetime -> :exchange_order_update_time
        :fillid -> :fill_id
        :filltime -> :fill_time
        :parentorderid -> :parent_order_id
        :uniqueorderid -> :unique_order_id
        x -> x
      end
    end

    def changeset(ch, attrs) do
      attrs = Encoder.underscore_keys(attrs, field_mapper())
      cast(ch, attrs, __MODULE__.__schema__(:fields))
    end

    def to_schema(data) do
      data = Encoder.underscore_keys(data, field_mapper())

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule OrderBook do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many(:orders, TradeGalleon.Brokers.AngelOne.Responses.OrderStatus)
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:orders)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{orders: data})
  end

  defmodule TradeBook do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many(:orders, TradeGalleon.Brokers.AngelOne.Responses.OrderStatus)
    end

    def to_schema(data) when is_map(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:orders)
      |> apply_action(:insert)
    end

    def to_schema(data), do: to_schema(%{trades: data})
  end

  defmodule SearchToken do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :scrips, Scrip do
        @derive Jason.Encoder
        field(:exchange, :string)
        field(:trading_symbol, :string)
        field(:symbol_token, :string)
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
      attrs =
        Encoder.underscore_keys(attrs, fn
          :tradingsymbol -> :trading_symbol
          :symboltoken -> :symbol_token
          x -> x
        end)

      cast(ch, attrs, __MODULE__.Scrip.__schema__(:fields))
    end
  end

  defmodule PlaceOrder do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:script, :string)
      field(:order_id, :string)
      field(:unique_order_id, :string)
    end

    def to_schema(data) do
      data =
        Encoder.underscore_keys(data, fn
          :orderid -> :order_id
          :uniqueorderid -> :unique_order_id
          x -> x
        end)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule ModifyOrder do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:order_id, :string)
      field(:unique_order_id, :string)
    end

    def to_schema(data) do
      data =
        Encoder.underscore_keys(data, fn
          :orderid -> :order_id
          :uniqueorderid -> :unique_order_id
          x -> x
        end)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule CancelOrder do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:order_id, :string)
      field(:unique_order_id, :string)
    end

    def to_schema(data) do
      data =
        Encoder.underscore_keys(data, fn
          :orderid -> :order_id
          :uniqueorderid -> :unique_order_id
          x -> x
        end)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule VerifyDis do
    use Ecto.Schema
    import Ecto.Changeset
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      field(:req_id, :string)
      field(:return_url, :string)
      field(:dp_id, :string)
      field(:boid, :string)
      field(:trans_dtls, :string)
      field(:version, :string)
    end

    def to_schema(data) do
      data = Encoder.underscore_keys(data)

      %__MODULE__{}
      |> cast(data, __MODULE__.__schema__(:fields))
      |> apply_action(:insert)
    end
  end

  defmodule EstimateCharges do
    use Ecto.Schema
    import Ecto.Changeset
    alias TradeGalleon.Brokers.AngelOne.Responses.EstimateCharges.Breakup
    @derive Jason.Encoder

    @primary_key false
    embedded_schema do
      embeds_many :breakup, Breakup do
        @derive Jason.Encoder
        field(:name, :string)
        field(:amount, :float)
        field(:msg, :string)
        embeds_many(:breakup, Breakup)
      end

      embeds_one :summary, Summary do
        @derive Jason.Encoder
        field(:total_charges, :float)
        field(:trade_value, :float)

        embeds_many(:breakup, Breakup)
      end

      embeds_many :charges, Charge do
        @derive Jason.Encoder
        field(:total_charges, :float)
        field(:trade_value, :float)
        embeds_many(:breakup, Breakup)
      end
    end

    def to_schema(data) do
      %__MODULE__{}
      |> cast(data, [])
      |> cast_embed(:summary, with: &summary_changeset/2)
      |> cast_embed(:charges, with: &charge_changeset/2)
      |> apply_action(:insert)
    end

    def summary_changeset(ch, attrs) do
      ch
      |> cast(attrs, __MODULE__.Summary.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end

    def charge_changeset(ch, attrs) do
      ch
      |> cast(attrs, __MODULE__.Charge.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end

    def breakup_changeset(ch, attrs) do
      ch
      |> cast(attrs, Breakup.__schema__(:fields) -- [:breakup])
      |> cast_embed(:breakup, with: &breakup_changeset/2)
    end
  end
end
