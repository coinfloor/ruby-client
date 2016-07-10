# Coinfloor's Ruby client library

Coinfloor's application programming interface (API) provides our clients
programmatic access to control aspects of their accounts and to place orders on
the Coinfloor trading platform. The Ruby client library exposes the Coinfloor
API to your Ruby application.

## Naming conventions

This client implementation uses different naming conventions than our API
specification. We are working hard to improve the documentation of this
implementation, but here are the main differences:

In the `Authenticate` method:
* `cookie` in the API spec is called `API_key` in the Ruby client.
* Private keys are constructed using Libecp, which is also used to construct
  the signatures.

For more details on the construction of private keys and signatures please
review [trade_api.rb].


## Installation

### Dependencies

This gem depends on the [Ruby LibECP gem](https://github.com/coinfloor/ruby-libecp).

Use the gem in a project managed with Bundler adding it into Gemfile:

    gem "cf-ruby-libecp"
    gem "cf-trade-client"

## Usage example

```ruby
require "trade_client"

# Create and connect with user id, password and API key
client = Coinfloor::CFClient.new("wss://api.coinfloor.co.uk", ID, "PASSWORD", "API_KEY")

# Get balances
client.get_balance

# Make sell order, quantity is a negative number
result = client.exec(:placeorder,{ base_asset_id: asset_btc,counter_asset_id: asset_gbp, quantity: -100000000, price: 1000 })
order_id = result["id"]

# Make buy order, quantity is a positive number
result = client.exec(:placeorder,{ base_asset_id: asset_btc,counter_asset_id: asset_gbp, quantity: 100000000, price: 100 })
order_id = result["id"]

# Get open orders
client.exec(:getorders, {})
```


## Extra notes

All connections to the Coinfloor's trade engine go through a load balancer.
Clients connecting via WebSocket should send a ping frame every 45 seconds or
so while the connection is otherwise idle. This prevents the load balancer from
dropping the connection.


## API

For an explanation of our API methods and what they return, please see our [API
specification](https://github.com/coinfloor/API).

An implementation of this API in Ruby can be seen in
[lib/trade_api/trade_api.rb][trade_api.rb]. This also lists the calls that this
library can make.

### Numbers and scale

All quantities and prices are transmitted and received as integers with
implicit scale factors. For scale information, please see
[SCALE.md](https://github.com/coinfloor/API/blob/master/SCALE.md).


## Licence

Released under the Apache License Version 2.0.


## Give us your feedback!

We're always looking to get as much feedback as we can. We want to hear your
opinion. [Contact us](http://support.coinfloor.co.uk/).


[trade_api.rb]: https://github.com/coinfloor/ruby-client/blob/master/lib/trade_api/trade_api.rb
