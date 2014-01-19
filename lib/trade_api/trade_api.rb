=begin
Copyright 2014 Coinfloor LTD.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'libecp'
require 'json'

module Coinfloor
  # The Coinfloor trade API
  # All method calls return json which is to be sent to the API.
  class CFcon
    # coinfloor user trade id, password
    def initialize(uid,password,api_key,pkey=nil)
      @uid=uid
      @uid_byte=LibEcp.gen_uid(uid)
      if pkey
        @private_key=pkey
      else
        @password=password
        @private_key=LibEcp.private_key(@uid_byte,password)

      end
      @public_key=LibEcp.gen_pub(@private_key)
      @cookie=api_key
      @password=nil
    end

    attr_reader  :public_key

    # Authenticate using your generated private key, pass in the nonce given by the server on initial authenticate open
    def auth(server_nonce)
      nonce=LibEcp.gen_nonce
      while nonce.bytes.count==15
        nonce=LibEcp.gen_nonce
      end
      sigs=LibEcp.sign(@uid_byte,Base64.decode64(server_nonce),nonce,@private_key)
      {
        "method"=>"Authenticate",
        "user_id"=>@uid,
        "cookie"=>@cookie,
        "nonce"=>Base64.encode64(nonce).rstrip,
        "signature"=>[Base64.encode64(sigs[0]).rstrip,Base64.encode64(sigs[1]).rstrip]
      }.to_json.gsub(/\s+/, "")
    end

    # Cancels users existing order, arguments: {:id=>order_id_integer}
    def cancelorder(args)
      {
        :method=>"CancelOrder",
        :id=>args[:id]
      }.to_json
    end

    # return any available balance, no arguments
    def getbalance(args={})
      {
        :method=> "GetBalances"
      }.to_json
    end

    # return a list of open orders, no arguments
    def getorders(args={})
      {
        :method=> "GetOrders"
      }.to_json
    end

    # Place an order,arguments:
    # {:base_asset_id=>integer,:counter_asset_id=>integer,:quantity=>integer,:price=>integer}
    # quantity is positive for a buy, negative for a sell
    def placeorder(arguments)

      {
        :method => "PlaceOrder",
        :base => arguments[:base_asset_id],
        :counter => arguments[:counter_asset_id],
        :quantity => arguments[:quantity],
        :price => arguments[:price]
      }.delete_if { |k, v| v.empty? }.to_json #removes empty values that might not be given as arguments
    end

    # Gets a copy of the orderbook, does not subscribe
    def orderbook(arguments)
      {
        :method => "WatchOrders",
        :base => arguments[:base_asset_id],
        :counter => arguments[:counter_asset_id],
        :watch => true
      }.to_json
    end
  end

end

