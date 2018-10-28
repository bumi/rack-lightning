# Rack::Lightning - micropayments for your rack app

[Rack middleware](https://rack.github.io/) for requesting Bitcoin [Lightning payments](http://lightning.network/) per request.

Status: alpha - proof of concept

## How does it work?

1. On the first request a Lightning invoice is created and th `402 Payment Required` HTTP status code is returend 
with a `application/vnd.lightning.bolt11` header and a Lightning invoice as a body.
2. Once the client has paid the invoice it does a second request providing the proof of payment / the preimage of the Lightning
payment in a `X-Preimage` header. The middleware checks the if the invoice was paid and continues with the rack app stack


Have a look at the [Faraday HTTP client middleware](https://github.com/bumi/faraday_ln_paywall) to automatically handle the 
payment of the requested invoice.

## Requirements

The middleware uses the gRPC service provided by the [Lightning Network Daemon(lnd)](https://github.com/lightningnetwork/lnd/).
A running node with is required which is used to generate and validate invoices.

Details about lnd can be found on their [github page](https://github.com/lightningnetwork/lnd/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-lightning'
```

## Usage

Simply add the `Rack::Lightning` middleware:

```ruby
require "rack/lightning"

Example = Rack::Builder.new {
  use Rack::Lightning, { price: 100 } 
  run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }
}.to_app
```

## Configuration 

The middleware accepts the following configuration options: 

* `price`: the price in satoshi (default: 100)
* `address`: the address of the lnd gRPC service( default: localhost:10009)
* `credentials_path`: path to the tls.cert (default: ~/.lnd/tls.cert)
* `macaroon_path`: path to the macaroon path (default: ~/.lnd/data/chain/bitcoin/testnet/admin.macaroon)

## What is the Lightning Network?

The [Lightning Network](https://en.wikipedia.org/wiki/Lightning_Network) allows to send real near-instant microtransactions with extremely low fees. 
It is a second layer on top of the Bitcoin network (and other crypto currencies). 
Thanks to this properties it can be used to monetize APIs. 

## Similar projects

* [philippgille/ln-paywall](https://github.com/philippgille/ln-paywall) - middleware for Go frameworks. looks great and very well designed!
* [ElementsProject/paypercall](https://github.com/ElementsProject/paypercall) - express.js middelware for node.js applications


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bumi/rack-lightning.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
