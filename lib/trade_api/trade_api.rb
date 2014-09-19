require "cf-ruby-libecp"
require "json"

module Coinfloor
  class CFcon
    # coinfloor user trade id, password
    def initialize(uid, password, api_key, pkey = nil)
      @uid = uid
      @uid_byte = LibEcp.gen_uid(uid)

      if pkey
        @private_key = pkey
      else
        @password = password
        @private_key = LibEcp.private_key(@uid_byte, password)
      end

      @public_key = LibEcp.gen_pub(@private_key)
      @cookie = api_key
      @password = nil
    end

    attr_reader :public_key

    # Authenticate using your generated private key, pass in the nonce given by
    # the server on initial authenticate open.
    def auth(server_nonce)
      nonce = LibEcp.gen_nonce
      while nonce.bytes.count == 15
        nonce = LibEcp.gen_nonce
      end

      sigs = LibEcp.sign(@uid_byte, Base64.decode64(server_nonce), nonce, @private_key)
      {
        "method"    => "Authenticate",
        "user_id"   => @uid,
        "cookie"    => @cookie,
        "nonce"     => Base64.encode64(nonce).rstrip,
        "signature" => [Base64.encode64(sigs[0]).rstrip, Base64.encode64(sigs[1]).rstrip]
      }.to_json.gsub(/\s+/, "")
    end

    # Cancels users existing order.
    def cancelorder(args)
      {
        :method => "CancelOrder",
        :id     => args[:id],
      }.to_json
    end

    # Return any available balance.
    def getbalance(args = {})
      {
        :method => "GetBalances",
      }.to_json
    end

    # Return a list of open orders.
    def getorders(args = {})
      {
        :method => "GetOrders",
      }.to_json
    end

    # Place an order.
    def placeorder(args)
      {
        :method   => "PlaceOrder",
        :base     => args[:base_asset_id],
        :counter  => args[:counter_asset_id],
        :quantity => args[:quantity],
        :price    => args[:price],
        :total    => args[:total],
      }.delete_if { |k, v| v.nil? }.to_json
    end

    # Gets a copy of the orderbook, does not subscribe.
    # The subscription connection is not working because we are not doing a
    # continious conection.
    def orderbook(args)
      {
        :method  => "WatchOrders",
        :base    => args[:base_asset_id],
        :counter => args[:counter_asset_id],
        :watch   => true,
      }.to_json
    end

    # Simulates the execution of a market order and returns the quantity and
    # total that would have been traded. This estimation does not take into
    # account trading fees.
    def estimatemarketorder(args)
      {
        :method   => "EstimateMarketOrder",
        :base     => args[:base_asset_id],
        :counter  => args[:counter_asset_id],
        :quantity => args[:quantity],
        :total    => args[:total],
      }.to_json
    end

    # Retrieves the 30-day trailing trade volume for the authenticated user.
    def gettradevolume(args)
      {
        :method => "GetTradeVolume",
        :asset  => args[:asset_id],
      }.to_json
    end
  end
end

