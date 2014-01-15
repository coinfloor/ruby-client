Gem::Specification.new do |s|
  s.name        = 'cf-trade-client'
  s.version     = '0.1.4'
  s.date        = '2014-01-15'
  s.summary     = "A ruby client library to trade on the Coinfloor platform using their API"
  s.description = "This client allows a user to trade on the coinfloor plaform using their API, it uses EventMachine and Faye websockets library as well as depending on the coinfloor libecp gem"
	s.add_dependency "faye-websocket","~> 0.7.2"
	s.add_dependency "cf-ruby-libecp","~> 0.1.0"
	s.add_dependency "json", "~> 1.8.1"
  s.authors     = ["Coinfloor"]
	s.required_ruby_version     = '>= 1.9.3'
  s.email       = 'development@coinfloor.co.uk'
  s.files       = ["lib/trade_client.rb","lib/client/client.rb","lib/trade_api/trade_api.rb"]
  s.homepage    = 'https://github.com/coinfloor/trade-client'
  s.license       = 'APACHE 2.0'
end
