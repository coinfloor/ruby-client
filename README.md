## Coinfloor trade client

Welcome to the Coinfloor ruby trade client implementation. You can use this example implementation to connect to the Coinfloor API which is currently in private beta. Coinfloor’s application programming interface (API) allows our clients to programmatically access and control aspects of their accounts and place orders on the Coinfloor trading platform.  The ruby trade client uses websockets to connect to our trading engine.

If you are interested in testing using a custom client either in ruby or using another programming language, feel free to use our libecp wrapper for signing,verifying signatures and generating keys. https://github.com/coinfloor/ruby-libecp

## Naming Conventions
As you've probably noticed our sample client implementation uses different naming conventions than our API standalone documentation. We are working hard to improve the documentation of this implementation, but here are the main differences:

In the Authenticate method: 
Cookie in the API.md file  is equal to API_key in the ruby client
Private keys are constructed using Libecp which is used to construct the signatures.

For more details with respect to the construction of private keys and signatures please review the trade_api.rb source file here

## Extra notes: 
All requests to the Coinfloor’s trading engine go through a load balancer. Clients connecting via websocket should send a ping frame every 45 seconds or so while the connection is otherwise idle. This prevents the load balancer from dropping the connection.

Asset codes: (these might be different when we go live)
Bitcoin: asset_btc=63488
British Pound: asset_gbp=64032


## Let us know your feedback!
We’re looking to get as much feedback as we can from this private beta. We know that there are a lot of areas in which we can improve and we would like to hear your opinion. Contact us at http://support.coinfloor.co.uk! 

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

All numbers given and recieved are integers, numbers entered and returned must be scaled up for down.

For scale information please see [SCALE.md] (SCALE.md)

### Sample usage
```ruby
require 'trade_client'

# Create and connect with user id,,password and API key

client=Coinfloor::CFClient.new("wss://api.coinfloor.co.uk",ID,"PASSWORD","API_KEY") 

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

## API

For an explanation of the API calls and what they return, please see [API.md](API.md)

An example of this API implemented in ruby can be seen in lib/trade_api/trade_api.rb , this also lists the calls that this library can make.

