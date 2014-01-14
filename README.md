## Coinfloor trade client

This library can be used with the provided websocket client (CFClient) or you can use CFcon (the trade API) to roll your own (since the provided websocket client implementation is quite slow).

It allows you to connect to the Coinfloor API and make trades.

## Licence
```
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
```

## Requirements
Relies on cf-ruby-libecp gem and Faye/websockets

## Installation

```
gem install cf-trade-client
```

## Usage

### Numbers and scale

All numbers given and recieved are integers

Scale is currently not available

```ruby
require 'trade_client'

#create new client and connect with user id 10 and password "apple"

client=Coinfloor::CFClient.new("ws://IP-GOES-HERE:8080",10,"apple") 

#asset codes (may be different in deployment)
asset_btc=63488
asset_gbp=64032

#get balances
client.get_balance
#make sell order, quantity is a negative number
result=client.exec(:placeorder,{base_asset_id: asset_btc,counter_asset_id: asset_gbp, quantity: -100000000, price: 1000 })
order_id=result["id"]

#make buy order, quantity is a positive number
result=client.exec(:placeorder,{base_asset_id: asset_btc,counter_asset_id: asset_gbp, quantity: 100000000, price: 100 })
order_id=result["id"]

#get open orders
client.exec(:getorders,{})
```



